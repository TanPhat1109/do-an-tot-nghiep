import 'package:flutter/material.dart';

class ChatHistoryDrawer extends StatelessWidget {
  final List<Map<String, dynamic>> conversations;
  final int? currentConversationId;
  final bool isDark;
  final bool isLoading;
  final VoidCallback onNewConversation;
  final VoidCallback onRefresh;
  final Function(int id) onOpenConversation;
  final Function(int id, String title) onRenameConversation;
  final Function(int id) onDeleteConversation;
  final VoidCallback onLogout;

  const ChatHistoryDrawer({
    super.key,
    required this.conversations,
    required this.currentConversationId,
    required this.isDark,
    required this.isLoading,
    required this.onNewConversation,
    required this.onRefresh,
    required this.onOpenConversation,
    required this.onRenameConversation,
    required this.onDeleteConversation,
    required this.onLogout,
  });

  // MÀU SẮC
  Color get _textColor => isDark ? Colors.white : const Color(0xFF172033);

  Color get _secondaryColor =>
      isDark ? Colors.white60 : const Color(0xFF71829F);

  Color get _dialogBackground =>
      isDark ? const Color(0xFF202C3D) : Colors.white;

  // STYLE CHỮ THỐNG NHẤT
  TextStyle get _itemTextStyle =>
      TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.w500);

  // ĐỔI TÊN CUỘC TRÒ CHUYỆN
  Future<void> _showRenameDialog(
    BuildContext context,
    int id,
    String currentTitle,
  ) async {
    final controller = TextEditingController(text: currentTitle);

    final newTitle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _dialogBackground,
        title: Text(
          'Đổi tên cuộc trò chuyện',
          style: TextStyle(
            color: _textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: _textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Nhập tên mới',
            hintStyle: TextStyle(color: _secondaryColor),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDark
                    ? const Color(0xFF52627A)
                    : const Color(0xFFD5DCE8),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6849ED), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Hủy',
              style: TextStyle(color: _secondaryColor, fontSize: 14),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();

              if (value.isNotEmpty) {
                Navigator.pop(dialogContext, value);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6849ED),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Lưu',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );

    controller.dispose();

    if (newTitle != null && newTitle.trim().isNotEmpty) {
      onRenameConversation(id, newTitle.trim());
    }
  }

  // XÓA CUỘC TRÒ CHUYỆN
  Future<void> _showDeleteDialog(
    BuildContext context,
    int id,
    String title,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _dialogBackground,
        title: Text(
          'Xóa cuộc trò chuyện?',
          style: TextStyle(
            color: _textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Bạn có chắc muốn xóa "$title" không?',
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF172033),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Hủy',
              style: TextStyle(color: _secondaryColor, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Xóa',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDeleteConversation(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark
        ? const Color(0xFF111A28)
        : const Color(0xFFF7F8FC);

    return Drawer(
      width: 300,
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5945ED), Color(0xFF8138ED)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'NexusRAG AI',
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: _secondaryColor),
                  ),
                ],
              ),
            ),

            // TẠO CUỘC TRÒ CHUYỆN MỚI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onNewConversation,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Cuộc trò chuyện mới',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6849ED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            // TIÊU ĐỀ LỊCH SỬ
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'LỊCH SỬ TRÒ CHUYỆN',
                      style: TextStyle(
                        color: _secondaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Làm mới',
                    onPressed: onRefresh,
                    icon: Icon(Icons.refresh, size: 19, color: _secondaryColor),
                  ),
                ],
              ),
            ),

            // DANH SÁCH LỊCH SỬ
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : conversations.isEmpty
                  ? Center(
                      child: Text(
                        'Chưa có cuộc trò chuyện nào',
                        style: TextStyle(color: _secondaryColor, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final item = conversations[index];
                        final id = (item['id'] as num).toInt();

                        final title =
                            item['title']?.toString() ?? 'Cuộc trò chuyện mới';

                        final selected = id == currentConversationId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: selected
                                ? (isDark
                                      ? const Color(0xFF293750)
                                      : const Color(0xFFEAE7FF))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.chat_bubble_outline,
                              size: 19,
                              color: selected
                                  ? const Color(0xFF8062F3)
                                  : _secondaryColor,
                            ),
                            title: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: _itemTextStyle.copyWith(
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                            onTap: () => onOpenConversation(id),
                            trailing: PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: _secondaryColor,
                                size: 19,
                              ),
                              color: isDark
                                  ? const Color(0xFF293750)
                                  : Colors.white,
                              onSelected: (value) {
                                if (value == 'rename') {
                                  _showRenameDialog(context, id, title);
                                } else if (value == 'delete') {
                                  _showDeleteDialog(context, id, title);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'rename',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: _textColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Đổi tên', style: _itemTextStyle),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Xóa',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Divider(
              color: isDark ? const Color(0xFF344258) : const Color(0xFFE5EAF2),
            ),

            // ĐĂNG XUẤT
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade400),
              title: Text('Đăng xuất', style: _itemTextStyle),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
