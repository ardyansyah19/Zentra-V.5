import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// Lapisan komunikasi HTTP ke backend Zentra. Backend yang sama ini
/// juga dipakai oleh Admin Dashboard (React) — sehingga data produk,
/// harga, dan stok selalu konsisten di kedua sisi.
class ApiService {
  static String? _token;

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('zentra_token');
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zentra_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('zentra_token');
  }

  static bool get isLoggedIn => _token != null;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  static Future<dynamic> _handle(http.Response res) async {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = (body is Map && body['error'] != null) ? body['error'] : 'Terjadi kesalahan (${res.statusCode})';
    throw ApiException(msg);
  }

  static Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path').replace(queryParameters: query);
    final res = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> data) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path');
    final res = await http.post(uri, headers: _headers, body: jsonEncode(data)).timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  static Future<dynamic> put(String path, Map<String, dynamic> data) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path');
    final res = await http.put(uri, headers: _headers, body: jsonEncode(data)).timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> data) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path');
    final res = await http.patch(uri, headers: _headers, body: jsonEncode(data)).timeout(const Duration(seconds: 15));
    return _handle(res);
  }

  static Future<dynamic> delete(String path) async {
    final uri = Uri.parse('${AppConfig.apiUrl}$path');
    final res = await http.delete(uri, headers: _headers).timeout(const Duration(seconds: 15));
    return _handle(res);
  }
}
