import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onNewConversation;

  const ChatAppBar({
    super.key,
    required this.title,
    required this.isDark,
    required this.onToggleTheme,
    required this.onNewConversation,
  });

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF172033);

    final backgroundColor = isDark ? const Color(0xFF151F2E) : Colors.white;

    return AppBar(
      // Tắt nút menu tự động của Flutter
      automaticallyImplyLeading: false,

      toolbarHeight: 76,
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 8,

      // Chỉ tạo MỘT nút menu tại đây
      leading: Builder(
        builder: (context) => IconButton(
          tooltip: 'Lịch sử trò chuyện',
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(Icons.menu_rounded),
        ),
      ),

      // Đường phân cách phía dưới AppBar
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark ? const Color(0xFF344258) : const Color(0xFFE5EAF2),
        ),
      ),

      // Logo và thông tin chatbot
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5945ED), Color(0xFF8138ED)],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NexusRAG AI',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white60
                              : const Color(0xFF71829F),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      // Các nút chức năng bên phải
      actions: [
        IconButton(
          tooltip: 'Cuộc trò chuyện mới',
          onPressed: onNewConversation,
          icon: const Icon(Icons.add_comment_outlined),
        ),

        IconButton(
          tooltip: isDark
              ? 'Chuyển sang chế độ sáng'
              : 'Chuyển sang chế độ tối',
          onPressed: onToggleTheme,
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        ),

        const SizedBox(width: 8),
      ],
    );
  }
}
