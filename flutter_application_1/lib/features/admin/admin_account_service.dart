import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../data/repositories/auth_repository.dart';

class AdminAccountService {
  final AuthRepository _authRepo = AuthRepository();

  // Lấy danh sách tài khoản
  Future<List<Map<String, dynamic>>> getUsers() async {
    final token = await _authRepo.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Phiên đăng nhập đã hết hạn!');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/admin/users'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data);
    }

    throw Exception(
      data is Map
          ? data['detail'] ?? 'Không thể tải danh sách tài khoản!'
          : 'Không thể tải danh sách tài khoản!',
    );
  }

  // Thay đổi quyền tài khoản
  Future<void> updateUserRole({
    required int userId,
    required String role,
  }) async {
    final token = await _authRepo.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Phiên đăng nhập đã hết hạn!');
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId/role'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'role': role}),
    );

    if (response.statusCode == 200) {
      return;
    }

    final data = jsonDecode(response.body);

    throw Exception(
      data is Map
          ? data['detail'] ?? 'Không thể cập nhật quyền tài khoản!'
          : 'Không thể cập nhật quyền tài khoản!',
    );
  }
}
