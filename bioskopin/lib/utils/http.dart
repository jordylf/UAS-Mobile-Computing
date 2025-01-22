import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  static String baseUrl = 'http://teknologi22.xyz/project_api/api_jordy/bioskopin-api';

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.get(url, headers: headers);
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool isJson = true,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    if (isJson) {
      headers ??= {};
      headers['Content-Type'] = 'application/json';
      return await http.post(url, headers: headers, body: jsonEncode(body));
    } else {
      return await http.post(url, headers: headers, body: body);
    }
  }

  static Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool isJson = true,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    if (isJson) {
      headers ??= {};
      headers['Content-Type'] = 'application/json';
      return await http.put(url, headers: headers, body: jsonEncode(body));
    } else {
      return await http.put(url, headers: headers, body: body);
    }
  }

  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.delete(url, headers: headers);
  }
}
