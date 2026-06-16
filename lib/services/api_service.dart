import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';

  Future<String?> login() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': '242410103037',
        'password': '242410103037',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['token'];
    }

    print(response.body);
    return null;
  }

  Future<bool> submitProduct({
    required String token,
    required String name,
    required int price,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products/submit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': 'https://github.com/qappybaraa/project-pbm',
      }),
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
