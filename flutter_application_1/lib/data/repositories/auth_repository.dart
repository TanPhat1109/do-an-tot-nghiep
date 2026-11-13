import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart';

class AuthRepository {
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }

    final error = jsonDecode(response.body);
    throw Exception(error['detail'] ?? 'Đăng ký thất bại!');
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Sai tài khoản hoặc mật khẩu!');
    }

    final data = jsonDecode(response.body);
    final token = data['access_token'] as String;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    // Lấy thông tin tài khoản để xác định role.
    final meResponse = await http.get(
      Uri.parse(ApiConfig.me),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (meResponse.statusCode != 200) {
      await prefs.remove('token');
      throw Exception('Không thể lấy thông tin tài khoản!');
    }

    final userData = jsonDecode(meResponse.body);
    final role = userData['role']?.toString();

    if (role == null) {
      await prefs.remove('token');
      throw Exception('API /auth/me không trả về role!');
    }

    await prefs.setString('role', role);

    return token;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
}
