import 'dart:convert';

import 'package:echolinkz/ui/widgets/EchoLinkZ_appbar.dart';
import 'package:echolinkz/utils/shared_prefs_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ReportDetailPage extends StatefulWidget {
  final Map<String, dynamic> report;
  const ReportDetailPage({super.key, required this.report});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  late IO.Socket socket;
  final List<Map<String, dynamic>> messages = [];
  final _msg = TextEditingController();
  final _scroll = ScrollController();
  bool sending = false;
  String? _userId;
  static const _host = 'http://localhost:5001';

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    _userId = await SharedPreferencesManager.getUser();
    _openSocket();
    await _loadHistory();
  }

  @override
  void dispose() {
    socket.dispose();
    _msg.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _openSocket() {
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
    socket.on(
        'receiveMessage',
        (d) =>
            setState(() => messages.insert(0, Map<String, dynamic>.from(d))));
  }

  Future<void> _loadHistory() async {
    final tk = await SharedPreferencesManager.getSessionToken();
    final r = await http.get(
      Uri.parse('$_host/api/messages/${widget.report['_id']}'),
      headers: {'Authorization': 'Bearer $tk'},
    );
    if (r.statusCode == 200) {
      final list = (jsonDecode(r.body) as List).reversed;
      setState(() =>
          messages.insertAll(0, list.map((e) => Map<String, dynamic>.from(e))));
    }
  }

  Future<void> _send() async {
    if (_msg.text.trim().isEmpty || sending) return;
    final txt = _msg.text.trim();
    _msg.clear();
    setState(() => sending = true);
    socket.emit('sendMessage', {
      'reportId': widget.report['_id'],
      'message': txt,
      'senderId': _userId,
    });
    setState(() => sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final th = Theme.of(context);

    return Scaffold(
      appBar: EchoLinkZAppBar(title: widget.report['title'] ?? 'Détails'),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Card(
                margin: const EdgeInsets.all(12),
                color: cs.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: cs.outline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_catIcon(widget.report['category']),
                              color: _catColor(widget.report['category'], cs)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.report['title'] ?? 'Sans titre',
                              style: th.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      if ((widget.report['description'] as String?)
                              ?.isNotEmpty ??
                          false)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(widget.report['description']!,
                              style: th.textTheme.bodyMedium),
                        ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            avatar: Icon(_catIcon(widget.report['category']),
                                color:
                                    _catColor(widget.report['category'], cs)),
                            label: Text(widget.report['category']
                                .toString()
                                .toUpperCase()),
                            backgroundColor:
                                _catColor(widget.report['category'], cs)
                                    .withOpacity(.15),
                          ),
                          Chip(
                            avatar:
                                Icon(Icons.flash_on, size: 18, color: cs.error),
                            label: Text('${widget.report['priority']}'),
                            backgroundColor: cs.surface,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _chatArea(cs)),
        ],
      ),
    );
  }

  Widget _chatArea(ColorScheme cs) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: cs.surface,
                  child: ListView.builder(
                    reverse: true,
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final m = messages[i];
                      final me = m['senderId'] == _userId;
                      final col = me ? cs.primary : cs.secondary;
                      final txt = me ? cs.onPrimary : cs.onSecondary;
                      return _Bubble(
                          text: m['message'],
                          isMe: me,
                          bubbleCol: col,
                          textCol: txt);
                    },
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceVariant,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msg,
                        minLines: 1,
                        maxLines: 1,
                        textInputAction:
                            TextInputAction.send,
                        decoration: InputDecoration(
                          hintText: 'Message…',
                          filled: true,
                          fillColor: cs.surface,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: cs.outline),
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    sending
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : IconButton(
                            icon: Icon(Icons.send, color: cs.primary),
                            onPressed: _send,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Color _catColor(String cat, ColorScheme cs) {
    switch (cat) {
      case 'eau':
        return cs.primary;
      case 'secours':
        return cs.error;
      case 'panne':
        return cs.tertiary;
      case 'abri':
        return cs.secondary;
      default:
        return cs.outline;
    }
  }

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'eau':
        return Icons.water_drop;
      case 'secours':
        return Icons.local_hospital;
      case 'panne':
        return Icons.car_repair;
      case 'abri':
        return Icons.home;
      default:
        return Icons.info;
    }
  }
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
    const rad = Radius.circular(18);
    final br = BorderRadius.only(
      topLeft: rad,
      topRight: rad,
      bottomLeft: isMe ? rad : Radius.zero,
      bottomRight: isMe ? Radius.zero : rad,
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
                offset: const Offset(0, 2))
          ],
        ),
        child: Text(text, style: TextStyle(color: textCol)),
      ),
    );
  }
}
