import 'dart:convert';
import 'package:echolinkz/utils/shared_prefs_manager.dart';
import 'package:echolinkz/ui/widgets/echolinkz_appbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatRoomPage extends StatefulWidget {
  final String room;
  const ChatRoomPage({super.key, required this.room});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late IO.Socket socket;
  final List<Map<String, dynamic>> msgs = [];
  final _txt = TextEditingController();
  final _scroll = ScrollController();
  String? _uid;
  static const _host = 'http://localhost:5001';
  bool get _isReport => RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(widget.room);

  @override
  void initState() {
    super.initState();
    SharedPreferencesManager.getUser().then((u) {
      _uid = u;
      _history();
      _socket();
    });
  }

  @override
  void dispose() {
    socket.dispose();
    _txt.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _history() async {
    final tk = await SharedPreferencesManager.getSessionToken();
    if (tk == null) return;
    final url = _isReport
        ? '$_host/api/messages/${widget.room}'
        : '$_host/api/messages/room/${Uri.encodeComponent(widget.room)}';
    final r = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $tk'});
    if (r.statusCode == 200) {
      final list = (jsonDecode(r.body) as List).reversed;
      setState(() => msgs.insertAll(0, list.map((e) => Map<String, dynamic>.from(e))));
      _jump();
    }
  }

  void _socket() {
    socket = IO.io(_host,
        IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());
    socket.connect();
    socket.onConnect((_) {
      socket.emit('joinRoom',
          _isReport ? {'reportId': widget.room} : {'room': widget.room});
    });
    socket.on('receiveMessage', (d) {
      setState(() => msgs.insert(0, Map<String, dynamic>.from(d)));
      _jump();
    });
  }

  void _send() {
    final t = _txt.text.trim();
    if (t.isEmpty) return;
    _txt.clear();
    socket.emit('sendMessage', {
      if (_isReport) 'reportId': widget.room else 'room': widget.room,
      'message': t,
      'senderId': _uid,
    });
  }

  void _jump() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients || !_scroll.position.hasContentDimensions) return;
      _scroll.jumpTo(_scroll.position.minScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: EchoLinkZAppBar(title: widget.room),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        border: Border.all(color: cs.outline),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              reverse: true,
                              controller: _scroll,
                              padding: const EdgeInsets.all(16),
                              itemCount: msgs.length,
                              itemBuilder: (_, i) {
                                final m = msgs[i];
                                final me = m['senderId'] == _uid;
                                final bg = me ? cs.primary : cs.secondary;
                                final fg = me ? cs.onPrimary : cs.onSecondary;
                                return _Bubble(
                                  text: m['message'],
                                  isMe: me,
                                  bubbleCol: bg,
                                  textCol: fg,
                                );
                              },
                            ),
                          ),
                          _inputBar(cs),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar(ColorScheme cs) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _txt,
                minLines: 1,
                maxLines: 1,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Message…',
                  filled: true,
                  fillColor: cs.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.outline),
                  ),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(icon: Icon(Icons.send, color: cs.primary), onPressed: _send),
          ],
        ),
      );
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.isMe,
    required this.bubbleCol,
    required this.textCol,
  });

  final String text;
  final bool isMe;
  final Color bubbleCol, textCol;

  @override
  Widget build(BuildContext context) {
    const r = Radius.circular(18);
    final br = BorderRadius.only(
      topLeft: r,
      topRight: r,
      bottomLeft: isMe ? r : Radius.zero,
      bottomRight: isMe ? Radius.zero : r,
    );
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        decoration: BoxDecoration(
          color: bubbleCol,
          borderRadius: br,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(text, style: TextStyle(color: textCol)),
      ),
    );
  }
}
