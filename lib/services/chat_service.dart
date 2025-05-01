import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:echolinkz/utils/shared_prefs_manager.dart';

class ChatService {
  static const _url = 'http://localhost:5001/api/chat';
  String? _threadId;

  Future<String> send(String text) async {
    final token = await SharedPreferencesManager.getSessionToken();
    final body = {
      'message': text.trim(),
      if (_threadId != null) 'threadId': _threadId,
    };

    final res = await http.post(
      Uri.parse(_url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('chat_error_${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    _threadId = data['threadId'] as String?;
    return data['answer'] as String;
  }
}