import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://reqres.in/api';

  static Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json',
        'x-api-key':'reqres-free-v1'
      },
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['token'];
    }
    return null;
  }

  static Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(
        headers: {'Content-Type': 'application/json',
    'x-api-key':'reqres-free-v1'
    },
        Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Failed to load users');
  }
}