import 'dart:convert';
import 'package:echolinkz/utils/shared_prefs_manager.dart';
import 'package:http/http.dart' as http;

class ReportService {
  final String _baseUrl = "http://localhost:5001/api/reports";

  Future<void> createReport({
    required String title,
    required String description,
    required String category,
    required int    priority,
    required double lat,
    required double lng,
  }) async {
    final body = {
      'title'      : title,
      'description': description,
      'category'   : category,
      'priority'   : priority,
      'location'   : {
        'type'       : 'Point',
        'coordinates': [lng, lat],
      },
    };

    final token = await SharedPreferencesManager.getSessionToken();
    if (token == null) {
      throw "Token de session non trouvé";
    }

    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 201) {
      throw "Erreur (${res.statusCode}) lors de la création du signalement";
    }
  }
}
