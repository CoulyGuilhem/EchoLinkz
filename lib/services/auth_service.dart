import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:echolinkz/utils/shared_prefs_manager.dart';

class AuthService {
  final String _apiBase = "http://localhost:5001/api/auth";

  Future<Response> login(String email, String password) async {
    final uri = Uri.parse('$_apiBase/signin');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final String token  = data['token'];
      final String userId = data['user']['id'];

      await SharedPreferencesManager.loginUser(userId, token);
    } else if (response.statusCode == 400) {
      throw "Email ou mot de passe incorrect";
    } else {
      throw "Erreur de connexion (${response.statusCode})";
    }

    return response;
  }

  Future<Response> register(
      String email, String username, String password) async {
    final uri = Uri.parse('$_apiBase/signup');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'email': email, 'username': username, 'password': password}),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final String token  = data['token'];
      final String userId = data['user']['id'];

      await SharedPreferencesManager.loginUser(userId, token);
    } else if (response.statusCode == 409) {
      throw "Un utilisateur existe déjà avec cet e-mail ou ce nom d'utilisateur";
    } else {
      throw "Erreur d’inscription (${response.statusCode})";
    }

    return response;
  }
}
