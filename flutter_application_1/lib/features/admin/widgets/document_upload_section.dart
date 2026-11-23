import 'package:flutter/material.dart';

class DocumentUploadSection extends StatelessWidget {
  final bool isUploading;
  final String? selectedFileName;
  final VoidCallback onUpload;

  const DocumentUploadSection({
    super.key,
    required this.isUploading,
    required this.selectedFileName,
    required this.onUpload,
  });

  static const Color purple = Color(0xFF5945ED);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              size: 34,
              color: purple,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Tải tài liệu lên hệ thống',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn tài liệu PDF, DOCX hoặc TXT để đưa vào kho tri thức.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Dung lượng tối đa: 10 MB',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          if (selectedFileName != null) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file_outlined, color: purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedFileName!,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isUploading ? null : onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isUploading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(
                isUploading ? 'ĐANG XỬ LÝ...' : 'CHỌN FILE VÀ TẢI LÊN',
              ),
            ),
          ),

          if (isUploading) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(color: purple),
            const SizedBox(height: 8),
            const Text(
              'Đang lưu tài liệu và tạo dữ liệu RAG...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
