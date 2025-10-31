import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = 'http://my-vps:3000'});

  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required List<Message> history,
    bool enableWebSearch = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'history': history.map((m) => m.toApiFormat()).toList(),
          'enable_web_search': enableWebSearch,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
