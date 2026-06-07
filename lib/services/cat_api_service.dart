import 'dart:convert';
import 'package:http/http.dart' as http;

class CatApiService {
  static const _baseUrl = 'https://api.thecatapi.com/v1';
  static const _apiKey =
      'live_7who1QW7U3igghQex3qPhKRGNSUo0szxRbiNl5FIk3HNuq73vsAdhJnEra0C6qv3';

  static Future<List<String>> fetchCatImageUrls(int count) async {
    final uri = Uri.parse('$_baseUrl/images/search?limit=$count');
    final response = await http.get(uri, headers: {'x-api-key': _apiKey});
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<String>((item) => item['url'] as String).toList();
    }
    return [];
  }
}
