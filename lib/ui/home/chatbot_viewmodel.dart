import 'package:echolinkz/services/chat_service.dart';
import 'package:flutter/material.dart';

class ChatbotViewModel extends ChangeNotifier {
  final _service = ChatService();
  final List<_Msg> _messages = [];
  List<_Msg> get messages => _messages;
  bool sending = false;

  Future<void> send(String text) async {
    if (sending || text.trim().isEmpty) return;
    sending = true;
    _messages.add(_Msg(text, true));
    notifyListeners();
    try {
      final reply = await _service.send(text.trim());
      _messages.add(_Msg(reply, false));
    } finally {
      sending = false;
      notifyListeners();
    }
  }
}

class _Msg {
  final String text;
  final bool fromUser;
  _Msg(this.text, this.fromUser);
}
