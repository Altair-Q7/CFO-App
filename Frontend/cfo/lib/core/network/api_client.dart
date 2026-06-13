import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'api_exception.dart';
import '../storage/token_storage.dart';

class ApiClient {
  final TokenStorage _tokenStorage;
  ApiClient(this._tokenStorage);

  Map<String, String> _headers({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (includeAuth) {
      final token = _tokenStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String path, {bool auth = true}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response = await http.get(uri, headers: _headers(includeAuth: auth));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response = await http.post(uri, headers: _headers(includeAuth: auth), body: body != null ? jsonEncode(body) : null);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response = await http.patch(uri, headers: _headers(includeAuth: auth), body: body != null ? jsonEncode(body) : null);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String path, {Map<String, dynamic>? body, bool auth = true}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response = await http.put(uri, headers: _headers(includeAuth: auth), body: body != null ? jsonEncode(body) : null);
    return _handleResponse(response);
  }

  Future<http.Response> getRaw(String path, {bool auth = true}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    return http.get(uri, headers: _headers(includeAuth: auth));
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: body is Map ? (body['error'] ?? body['message'] ?? 'Unknown error') : 'Unknown error',
      );
    }
  }
}