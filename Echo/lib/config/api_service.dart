import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080/';

  Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final uri = Uri.parse('$baseUrl$path');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Se o corpo estiver vazio, retorna objeto vazio
      return response.body.isEmpty ? {} : jsonDecode(response.body);
    } else {
      throw Exception('Request failed: ${response.body}');
    }
  }

  Future<dynamic> get(String path, {String? token}) async {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final uri = Uri.parse('$baseUrl$path');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return response.body.isEmpty ? {} : jsonDecode(response.body);
    } else {
      throw Exception('Request failed: ${response.body}');
    }
  }

  Future<dynamic> put(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final uri = Uri.parse('$baseUrl$path');

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body.isEmpty ? {} : jsonDecode(response.body);
    } else {
      throw Exception('Request failed: ${response.body}');
    }
  }

  String? extractUrlFromResponse(String responseBody) {
    try {
      final Map<String, dynamic> json = jsonDecode(responseBody);
      return json['url'];
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> delete(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final uri = Uri.parse('$baseUrl$path');

    final response = await http.delete(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } else {
      throw Exception('Request failed: ${response.body}');
    }
  }
}
