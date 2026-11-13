import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../data/repositories/auth_repository.dart';
import '../../auth/screens/auth_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // API FastAPI
  static const String chatApi = 'http://127.0.0.1:8000/api/ai/chat';

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'bot',
      'text': 'Xin chào! Tôi là trợ lý AI RAG. Bạn muốn hỏi điều gì hôm nay?',
      'sources': [],
    },
  ];

  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _authRepo = AuthRepository();

  int? _conversationId;
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();

    if (text.isEmpty || _isLoading) return;

    _inputController.clear();

    setState(() {
      _messages.add({'sender': 'user', 'text': text, 'sources': []});

      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // 1. Lấy JWT đã lưu khi đăng nhập
      final token = await _authRepo.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Bạn chưa đăng nhập. Vui lòng đăng nhập lại.');
      }

      // 2. Tạo dữ liệu gửi lên FastAPI
      final body = {'question': text, 'conversation_id': _conversationId};

      // 3. Gọi API Chat RAG
      final response = await http
          .post(
            Uri.parse(chatApi),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 120));

      if (!mounted) return;

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // 4. Lưu conversation ID để tiếp tục hội thoại
        _conversationId = data['conversation_id'];

        final answer = data['answer'] ?? 'AI chưa có câu trả lời.';

        final sources = data['sources'] ?? [];

        setState(() {
          _messages.add({'sender': 'bot', 'text': answer, 'sources': sources});
        });
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.');
      } else if (response.statusCode == 403) {
        throw Exception('Bạn không có quyền thực hiện thao tác này.');
      } else {
        throw Exception(data['detail'] ?? 'Không thể kết nối AI Backend.');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': 'Lỗi: ${e.toString().replaceFirst('Exception: ', '')}',
          'sources': [],
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _logout() async {
    await _authRepo.logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Q&A RAG Chatbot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('AI đang suy nghĩ...'),
                    ),
                  );
                }

                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.80,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          msg['text'].toString(),
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                          ),
                        ),

                        // Hiển thị nguồn tài liệu RAG
                        if (!isUser && (msg['sources'] as List).isNotEmpty) ...[
                          const Divider(),
                          const Text(
                            'Nguồn tài liệu tham khảo:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 5),

                          ...(msg['sources'] as List).map((source) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                '• ${source['filename']} '
                                '(độ tương đồng: '
                                '${((source['similarity'] ?? 0) * 100).toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    enabled: !_isLoading,
                    decoration: const InputDecoration(
                      hintText: 'Nhập câu hỏi tri thức...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton.filled(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
