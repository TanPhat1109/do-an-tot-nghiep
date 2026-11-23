import 'package:flutter/material.dart';

class DocumentItem extends StatelessWidget {
  final Map<String, dynamic> document;
  final VoidCallback onDelete;

  const DocumentItem({
    super.key,
    required this.document,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rawFilename = document['filename']?.toString() ?? 'Không có tên';

    // Bỏ mã hash 32 ký tự ở đầu tên file
    final filename = RegExp(r'^[a-fA-F0-9]{32}_').hasMatch(rawFilename)
        ? rawFilename.substring(33)
        : rawFilename;
    final status = document['status']?.toString() ?? 'unknown';
    final chunks = document['total_chunks']?.toString() ?? '0';
    final id = document['id']?.toString() ?? '';

    final extension = filename.contains('.')
        ? filename.split('.').last.toUpperCase()
        : 'FILE';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF5945ED).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.insert_drive_file_outlined,
              color: Color(0xFF5945ED),
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$extension  •  ID: $id  •  $chunks chunks',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Trạng thái: $status',
                  style: TextStyle(
                    fontSize: 12,
                    color: status == 'processed' ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Xóa tài liệu',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
