import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isDark;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message['sender'] == 'user';
    final sources = message['sources'] as List? ?? [];

    final userColor = const Color(0xFF5144E9);
    final botColor = isDark ? const Color(0xFF202B3C) : Colors.white;

    final textColor = isDark ? Colors.white : const Color(0xFF263449);

    final secondaryColor = isDark ? Colors.white70 : const Color(0xFF71829F);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? userColor : botColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: isDark
                      ? const Color(0xFF344258)
                      : const Color(0xFFE4EAF3),
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nội dung tin nhắn
            SelectableText(
              message['text']?.toString() ?? '',
              style: TextStyle(
                color: isUser ? Colors.white : textColor,
                fontSize: 15,
                height: 1.6,
              ),
            ),

            // Nguồn tài liệu
            if (!isUser && sources.isNotEmpty) ...[
              const SizedBox(height: 14),
              Divider(color: isDark ? Colors.white24 : const Color(0xFFE4EAF3)),
              const SizedBox(height: 5),

              Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 17,
                    color: isDark
                        ? const Color(0xFF9B8AFF)
                        : const Color(0xFF5945ED),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Nguồn tài liệu tham khảo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ...sources.map((source) {
                final rawFilename =
                    source['filename']?.toString() ?? 'Tài liệu';

                final filename =
                    RegExp(r'^[a-fA-F0-9]{32}_').hasMatch(rawFilename)
                    ? rawFilename.substring(33)
                    : rawFilename;

                final similarity = ((source['similarity'] ?? 0) as num)
                    .toDouble();

                return Container(
                  margin: const EdgeInsets.only(bottom: 7),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF172234)
                        : const Color(0xFFF5F7FC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: secondaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              filename,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Độ tương đồng: '
                              '${(similarity * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 11,
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
