import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;
  final bool isDark;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.isLoading,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF263449);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151F2E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF344258) : const Color(0xFFE5EAF2),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF202B3C) : const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF344258)
                    : const Color(0xFFDDE5F0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: !isLoading,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) {
                      if (!isLoading) onSend();
                    },
                    style: TextStyle(color: textColor, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Nhập câu hỏi tri thức của bạn...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF9AA9BF),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5144E9), Color(0xFF8138ED)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    tooltip: 'Gửi câu hỏi',
                    onPressed: isLoading ? null : onSend,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
