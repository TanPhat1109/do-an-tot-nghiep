import 'package:flutter/material.dart';

class UploadResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const UploadResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget resultRow(String title, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 115,
              child: Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 9),
              Text(
                'Xử lý thành công',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          resultRow('Tên tài liệu', '${result['original_filename'] ?? ''}'),
          resultRow('Document ID', '${result['document_id'] ?? ''}'),
          resultRow('Số chunks', '${result['total_chunks'] ?? ''}'),
          resultRow('Trạng thái', '${result['status'] ?? ''}'),
          if (result['message'] != null) ...[
            const SizedBox(height: 8),
            Text(
              '${result['message']}',
              style: const TextStyle(color: Colors.green, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
