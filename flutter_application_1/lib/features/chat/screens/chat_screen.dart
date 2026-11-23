import 'package:flutter/material.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../auth/screens/auth_screen.dart';

import '../services/chat_service.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_history_drawer.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final AuthRepository _authRepo = AuthRepository();

  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, dynamic>> _conversations = [];

  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  int? _conversationId;
  String _conversationTitle = 'Cuộc trò chuyện mới';

  bool _isLoading = false;
  bool _isLoadingHistory = false;
  bool _isDark = false;

  @override
  void initState() {
    super.initState();

    _messages.add(_welcomeMessage());
    _loadConversations();
  }

  Map<String, dynamic> _welcomeMessage() {
    return {
      'sender': 'bot',
      'text': 'Xin chào! Tôi là trợ lý AI RAG. Bạn muốn hỏi điều gì hôm nay?',
      'sources': [],
    };
  }

  // ==========================================
  // 1. TẢI LỊCH SỬ TRÒ CHUYỆN
  // ==========================================

  Future<void> _loadConversations() async {
    if (_isLoadingHistory) return;

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final data = await _chatService.getConversations();

      if (!mounted) return;

      setState(() {
        _conversations
          ..clear()
          ..addAll(data);
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage('Lỗi tải lịch sử: ${_errorText(e)}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  // ==========================================
  // 2. TẠO CUỘC TRÒ CHUYỆN MỚI
  // ==========================================

  Future<void> _createNewConversation() async {
    if (_isLoading) return;

    try {
      final data = await _chatService.createConversation();

      if (!mounted) return;

      setState(() {
        _conversationId = data['conversation_id'];
        _conversationTitle = data['title'] ?? 'Cuộc trò chuyện mới';

        _messages
          ..clear()
          ..add(_welcomeMessage());

        _inputController.clear();
      });

      await _loadConversations();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Lỗi: ${_errorText(e)}');
    }
  }

  // ==========================================
  // 3. MỞ CUỘC TRÒ CHUYỆN CŨ
  // ==========================================

  Future<void> _openConversation(int conversationId) async {
    if (_isLoading) return;

    Navigator.pop(context);

    try {
      final data = await _chatService.getConversation(conversationId);

      if (!mounted) return;

      final List<dynamic> history = data['messages'] ?? [];

      setState(() {
        _conversationId = conversationId;
        _conversationTitle = data['title'] ?? 'Cuộc trò chuyện mới';

        _messages.clear();

        if (history.isEmpty) {
          _messages.add(_welcomeMessage());
        } else {
          for (final message in history) {
            _messages.add({
              'sender': message['sender_type'],
              'text': message['content'],
              'sources': [],
            });
          }
        }

        _inputController.clear();
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Lỗi: ${_errorText(e)}');
    }
  }

  // ==========================================
  // 4. ĐỔI TÊN HỘI THOẠI
  // ==========================================

  Future<void> _renameConversation(int conversationId, String newTitle) async {
    try {
      await _chatService.renameConversation(conversationId, newTitle);

      if (!mounted) return;

      if (_conversationId == conversationId) {
        setState(() {
          _conversationTitle = newTitle;
        });
      }

      await _loadConversations();

      if (!mounted) return;

      _showMessage('Đổi tên thành công.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Lỗi: ${_errorText(e)}');
    }
  }

  // ==========================================
  // 5. XÓA HỘI THOẠI
  // ==========================================

  Future<void> _deleteConversation(int conversationId) async {
    try {
      await _chatService.deleteConversation(conversationId);

      if (!mounted) return;

      if (_conversationId == conversationId) {
        setState(() {
          _conversationId = null;
          _conversationTitle = 'Cuộc trò chuyện mới';

          _messages
            ..clear()
            ..add(_welcomeMessage());
        });
      }

      await _loadConversations();

      if (!mounted) return;

      _showMessage('Đã xóa hội thoại.');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Lỗi: ${_errorText(e)}');
    }
  }

  // ==========================================
  // 6. GỬI CÂU HỎI CHO CHATBOT RAG
  // ==========================================

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
      final data = await _chatService.sendMessage(text, _conversationId);

      if (!mounted) return;

      setState(() {
        _conversationId = data['conversation_id'];

        _messages.add({
          'sender': 'bot',
          'text': data['answer'] ?? 'AI chưa có câu trả lời.',
          'sources': data['sources'] ?? [],
        });
      });

      await _loadConversations();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': 'Lỗi: ${_errorText(e)}',
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

  // ==========================================
  // 7. CUỘN XUỐNG CUỐI
  // ==========================================

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

  // ==========================================
  // 8. ĐĂNG XUẤT
  // ==========================================

  Future<void> _logout() async {
    await _authRepo.logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  // ==========================================
  // 9. CHUYỂN ĐỔI GIAO DIỆN SÁNG / TỐI
  // ==========================================

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  // ==========================================
  // 10. HIỂN THỊ THÔNG BÁO
  // ==========================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _errorText(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  // ==========================================
  // 11. BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isDark
        ? const Color(0xFF0D1522)
        : const Color(0xFFF7F8FC);

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: ChatAppBar(
        title: _conversationTitle,
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
        onNewConversation: _createNewConversation,
      ),

      drawer: ChatHistoryDrawer(
        conversations: _conversations,
        currentConversationId: _conversationId,
        isDark: _isDark,
        isLoading: _isLoadingHistory,

        onNewConversation: () {
          Navigator.pop(context);
          _createNewConversation();
        },

        onRefresh: _loadConversations,

        onOpenConversation: _openConversation,

        onRenameConversation: _renameConversation,

        onDeleteConversation: _deleteConversation,

        onLogout: _logout,
      ),

      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isLoading && index == _messages.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'AI đang suy nghĩ...',
                                style: TextStyle(
                                  color: _isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ChatMessageBubble(
                        message: _messages[index],
                        isDark: _isDark,
                      );
                    },
                  ),
          ),

          ChatInputBar(
            controller: _inputController,
            onSend: _sendMessage,
            isLoading: _isLoading,
            isDark: _isDark,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
