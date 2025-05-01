import 'dart:convert';
import 'package:echolinkz/utils/shared_prefs_manager.dart';
import 'package:echolinkz/ui/widgets/EchoLinkZ_appbar.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class ChatRoomPage extends StatefulWidget {
  final String room;
  const ChatRoomPage({Key? key, required this.room}) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  String? _userId;
  static const _host = 'http://localhost:5001';

  bool get _isReportRoom => RegExp(r'^[0-9a-fA-F]{24}\$').hasMatch(widget.room);

  @override
  void initState() {
    super.initState();
    SharedPreferencesManager.getUser().then((id) {
      _userId = id;
      _loadHistory();
      _initSocket();
    });
  }

  Future<void> _loadHistory() async {
    final token = await SharedPreferencesManager.getSessionToken();
    if (token == null) return;
    final url = _isReportRoom
        ? '$_host/api/messages/${widget.room}'
        : '$_host/api/messages/room/${Uri.encodeComponent(widget.room)}';
    try {
      final res = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final List<dynamic> list = jsonDecode(res.body);
        setState(() {
          messages = list.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      }
    } catch (_) {}
  }

  void _initSocket() {
    socket = IO.io(
      _host,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    socket.connect();
    socket.onConnect((_) {
      socket.emit('joinRoom', _isReportRoom
          ? {'reportId': widget.room}
          : {'room': widget.room});
    });
    socket.on('receiveMessage', (data) {
      setState(() {
        messages.add(Map<String, dynamic>.from(data));
      });
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final payload = {
      'message': text,
      'senderId': _userId,
      if (_isReportRoom) 'reportId': widget.room else 'room': widget.room,
    };
    socket.emit('sendMessage', payload);
  }

  @override
  void dispose() {
    socket.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EchoLinkZAppBar(title: widget.room),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final m = messages[i];
                final me = m['senderId'] == _userId;
                return Align(
                  alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: me
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      m['message'],
                      style: TextStyle(
                        color: me ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Message…',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
