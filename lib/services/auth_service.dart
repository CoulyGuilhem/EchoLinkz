import 'dart:convert';

// import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:echolinkz/utils/shared_prefs_manager.dart';

class AuthService {
  Future<Response> login(String email, String password) async {
    //TODO: Uncomment this code when api is ready

    // String api = "http://localhost:3000";
    // Uri apiUrl = Uri.parse('$api/login');

    // final response = await http.post(
    //   apiUrl,
    //   headers: {
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode({
    //     'email': email,
    //     'password': password,
    //   }),
    // );

    final response = Response('''{
  "session_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiNWYzZjQwZjQwZjQwZjQwZjQwZjQwZjQwIiwic2Vzc2lvbl90b2tlbiI6IjE2Mjg4NzYwNzIwNzIiLCJpYXQiOjE2Mjg4NzYwNzJ9.1",
  "user_id": "5f3f40f40f40f40f40f40f40"
}''', 200);

    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      final String sessionToken = responseData['session_token'];
      final String userId = responseData['user_id'];
      await SharedPreferencesManager.loginUser(userId, sessionToken);
    } else {
      if (response.statusCode == 401) {
        throw "Email ou mot de passe incorrect";
      }
    }

    return response;
  }

  Future<Response> register(String email, String password) async {
    // TODO: Uncomment this code when api is ready
    //
    // final api  = "http://localhost:3000";
    // final url  = Uri.parse('$api/register');
    // final res  = await http.post(
    //   url,
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({'email': email, 'password': password}),
    // );

    final res = Response('''{
    "session_token": "dummy.jwt.token",
    "user_id": "new_user_id"
  }''', 201);

    if (res.statusCode == 201) {
      final data = json.decode(res.body);
      await SharedPreferencesManager.loginUser(
        data['user_id'],
        data['session_token'],
      );
    } else if (res.statusCode == 409) {
      throw "Un utilisateur existe déjà avec cette adresse email";
    }

    return res;
  }
}
