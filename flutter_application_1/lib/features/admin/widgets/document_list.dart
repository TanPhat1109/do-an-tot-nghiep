import 'package:flutter/material.dart';
import 'document_item.dart';

class DocumentList extends StatelessWidget {
  final List<Map<String, dynamic>> documents;
  final bool isLoading;
  final ValueChanged<int> onDelete;

  const DocumentList({
    super.key,
    required this.documents,
    required this.isLoading,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (documents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.folder_open_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Chưa có tài liệu nào',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: documents.map((document) {
        return DocumentItem(
          document: document,
          onDelete: () {
            final id = int.tryParse(document['id'].toString());
            if (id != null) onDelete(id);
          },
        );
      }).toList(),
    );
  }
}
