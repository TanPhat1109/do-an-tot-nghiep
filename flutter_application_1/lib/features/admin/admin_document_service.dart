import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../data/repositories/auth_repository.dart';

class AdminDocumentService {
  final AuthRepository _authRepo = AuthRepository();

  Future<String> _getToken() async {
    final token = await _authRepo.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Phiên đăng nhập hết hạn!');
    }

    return token;
  }

  dynamic _decode(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  // Lấy danh sách tài liệu
  Future<List<Map<String, dynamic>>> getDocuments() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/documents/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = _decode(response);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(data['documents'] ?? []);
    }

    throw Exception(data['detail'] ?? 'Không thể tải danh sách tài liệu!');
  }

  // Upload tài liệu
  Future<Map<String, dynamic>> uploadDocument({
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final token = await _getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/documents/upload'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(minutes: 3),
    );

    final response = await http.Response.fromStream(streamedResponse);
    final data = _decode(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail'] ?? 'Upload tài liệu thất bại!');
  }

  // Xóa tài liệu
  Future<void> deleteDocument(int documentId) async {
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/documents/$documentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = _decode(response);

    if (response.statusCode == 200 && data['success'] == true) {
      return;
    }

    throw Exception(data['detail'] ?? 'Không thể xóa tài liệu!');
  }
}
