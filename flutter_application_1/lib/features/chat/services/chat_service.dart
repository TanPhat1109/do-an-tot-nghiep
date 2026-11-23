import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../data/repositories/auth_repository.dart';

class ChatService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String chatApi = '$baseUrl/api/ai/chat';
  static const String conversationApi = '$baseUrl/api/conversations';

  final AuthRepository _authRepo = AuthRepository();

  // Lấy token đăng nhập
  Future<String> _getToken() async {
    final token = await _authRepo.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Bạn chưa đăng nhập. Vui lòng đăng nhập lại.');
    }

    return token;
  }

  // Header gửi lên FastAPI
  Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Giải mã JSON UTF-8
  dynamic _decodeResponse(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  // 1. LẤY DANH SÁCH HỘI THOẠI
  Future<List<Map<String, dynamic>>> getConversations() async {
    final response = await http
        .get(Uri.parse('$conversationApi/'), headers: await _headers())
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = _decodeResponse(response);

      return List<Map<String, dynamic>>.from(data);
    }

    if (response.statusCode == 401) {
      throw Exception('Phiên đăng nhập hết hạn.');
    }

    throw Exception('Không thể tải lịch sử trò chuyện.');
  }

  // 2. TẠO HỘI THOẠI MỚI
  Future<Map<String, dynamic>> createConversation() async {
    final response = await http
        .post(
          Uri.parse('$conversationApi/'),
          headers: await _headers(),
          body: jsonEncode({'title': 'Cuộc trò chuyện mới'}),
        )
        .timeout(const Duration(seconds: 30));

    final data = _decodeResponse(response);

    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail'] ?? 'Không thể tạo hội thoại mới.');
  }

  // 3. MỞ HỘI THOẠI CŨ
  Future<Map<String, dynamic>> getConversation(int conversationId) async {
    final response = await http
        .get(
          Uri.parse('$conversationApi/$conversationId'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 30));

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    throw Exception(data['detail'] ?? 'Không thể mở hội thoại.');
  }

  // 4. ĐỔI TÊN HỘI THOẠI
  Future<void> renameConversation(int conversationId, String newTitle) async {
    final response = await http
        .put(
          Uri.parse('$conversationApi/$conversationId'),
          headers: await _headers(),
          body: jsonEncode({'title': newTitle}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Không thể đổi tên hội thoại.');
    }
  }

  // 5. XÓA HỘI THOẠI
  Future<void> deleteConversation(int conversationId) async {
    final response = await http
        .delete(
          Uri.parse('$conversationApi/$conversationId'),
          headers: await _headers(),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Không thể xóa hội thoại.');
    }
  }

  // 6. GỬI CÂU HỎI ĐẾN CHATBOT RAG
  Future<Map<String, dynamic>> sendMessage(
    String question,
    int? conversationId,
  ) async {
    final response = await http
        .post(
          Uri.parse(chatApi),
          headers: await _headers(),
          body: jsonEncode({
            'question': question,
            'conversation_id': conversationId,
          }),
        )
        .timeout(const Duration(seconds: 120));

    final data = _decodeResponse(response);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data);
    }

    if (response.statusCode == 401) {
      throw Exception('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.');
    }

    if (response.statusCode == 403) {
      throw Exception('Bạn không có quyền thực hiện thao tác này.');
    }

    throw Exception(data['detail'] ?? 'Không thể kết nối AI Backend.');
  }
}
