import 'dart:convert';
import 'package:echolinkz/utils/shared_prefs_manager.dart';
import 'package:echolinkz/ui/widgets/EchoLinkZ_appbar.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class ReportDetailPage extends StatefulWidget {
  final Map<String, dynamic> report;
  const ReportDetailPage({super.key, required this.report});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _msgController = TextEditingController();
  bool _isSending = false;
  String? _userId;
  static const _host = 'http://localhost:5001'; 

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _connectSocket();
    _loadHistory();
  }

  Future<void> _loadCurrentUser() async {
    _userId = await SharedPreferencesManager.getUser();
  }

  void _connectSocket() {
    socket = IO.io(
      _host,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    socket.connect();
    socket.onConnect((_) {
      socket.emit('joinRoom', {'reportId': widget.report['_id']});
    });
    socket.on('receiveMessage', (data) {
      setState(() {
        messages.add(Map<String, dynamic>.from(data));
      });
    });
  }

  Future<void> _loadHistory() async {
    final token = await SharedPreferencesManager.getSessionToken();
    final res = await http.get(
      Uri.parse('$_host/api/messages/${widget.report['_id']}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final List<dynamic> list = jsonDecode(res.body);
      setState(() {
        messages = list.map((m) => Map<String, dynamic>.from(m)).toList();
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    setState(() => _isSending = true);
    final msg = {
      'reportId': widget.report['_id'],
      'message': text,
      'senderId': _userId,
    };
    socket.emit('sendMessage', msg);
    setState(() => _isSending = false);
  }

  Future<void> _proposeHelp() async {
    final token = await SharedPreferencesManager.getSessionToken();
    final res = await http.post(
      Uri.parse('$_host/api/responses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'reportId': widget.report['_id']}),
    );
    final text = res.statusCode == 201 ? 'Aide proposée !' : 'Erreur : ${res.statusCode}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    socket.dispose();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EchoLinkZAppBar(title: widget.report['title'] ?? 'Détails'),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.report['title'] ?? 'Sans titre',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if ((widget.report['description'] as String?)
                          ?.isNotEmpty ??
                      false)
                    Text(
                      widget.report['description']!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          widget.report['category']
                                  ?.toString()
                                  .toUpperCase() ??
                              '',
                          style:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        avatar:
                            const Icon(Icons.priority_high, size: 18),
                        label:
                            Text('${widget.report['priority'] ?? '-'}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _proposeHelp,
                    icon: const Icon(Icons.volunteer_activism),
                    label: const Text('Proposer de l’aide'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final isMe = m['senderId'] == _userId;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Theme.of(context)
                                    .colorScheme.primary
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            m['message'],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
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
                            controller: _msgController,
                            decoration: InputDecoration(
                              hintText: 'Tapez un message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _isSending
                            ? const CircularProgressIndicator()
                            : IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: _sendMessage,
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
