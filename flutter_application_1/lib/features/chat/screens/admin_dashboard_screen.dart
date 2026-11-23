import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../auth/screens/auth_screen.dart';

import '../../admin/admin_document_service.dart';
import '../../admin/widgets/account_management_page.dart';
import '../../admin/widgets/document_search_bar.dart';
import '../../admin/widgets/document_list.dart';
import '../../admin/widgets/document_upload_section.dart';
import '../../admin/widgets/upload_result_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthRepository _authRepo = AuthRepository();
  final AdminDocumentService _documentService = AdminDocumentService();

  bool _isUploading = false;
  bool _isLoadingDocuments = false;

  int _selectedPage = 0;

  String? _selectedFileName;
  String _searchQuery = '';

  Map<String, dynamic>? _uploadResult;

  List<Map<String, dynamic>> _documents = [];

  static const Color purple = Color(0xFF5945ED);

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    if (mounted) {
      setState(() => _isLoadingDocuments = true);
    }

    try {
      final documents = await _documentService.getDocuments();

      if (!mounted) return;

      setState(() => _documents = documents);
    } catch (e) {
      _showMessage('Lỗi tải tài liệu: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoadingDocuments = false);
      }
    }
  }

  Future<void> _deleteDocument(int documentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa tài liệu này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _documentService.deleteDocument(documentId);
      _showMessage('Đã xóa tài liệu thành công!');
      await _loadDocuments();
    } catch (e) {
      _showMessage('Lỗi xóa tài liệu: $e', isError: true);
    }
  }

  Future<void> _logout() async {
    await _authRepo.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (route) => false,
    );
  }

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      if (file.bytes == null) {
        _showMessage('Không đọc được nội dung file!', isError: true);
        return;
      }

      if (file.size > 10 * 1024 * 1024) {
        _showMessage('File không được vượt quá 10 MB!', isError: true);
        return;
      }

      setState(() {
        _selectedFileName = file.name;
        _isUploading = true;
        _uploadResult = null;
      });

      final data = await _documentService.uploadDocument(
        fileName: file.name,
        fileBytes: file.bytes!,
      );

      if (!mounted) return;

      setState(() => _uploadResult = data);

      _showMessage('Upload tài liệu thành công!');
      await _loadDocuments();
    } catch (e) {
      _showMessage('Lỗi upload: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredDocuments {
    if (_searchQuery.trim().isEmpty) return _documents;

    return _documents.where((document) {
      final filename = document['filename']?.toString().toLowerCase() ?? '';

      return filename.contains(_searchQuery.trim().toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                color: purple,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'ADMIN PORTAL',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _selectedPage = 0),
            icon: Icon(
              Icons.people_outline,
              color: _selectedPage == 0 ? purple : theme.colorScheme.onSurface,
            ),
            label: Text(
              'Tài khoản',
              style: TextStyle(
                color: _selectedPage == 0
                    ? purple
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _selectedPage = 1),
            icon: Icon(
              Icons.folder_open_outlined,
              color: _selectedPage == 1 ? purple : theme.colorScheme.onSurface,
            ),
            label: Text(
              'Tài liệu',
              style: TextStyle(
                color: _selectedPage == 1
                    ? purple
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Tải lại danh sách',
            onPressed: _selectedPage == 0 ? null : _loadDocuments,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedPage == 0)
                  const AccountManagementPage()
                else
                  _buildDocumentPage(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentPage(ThemeData theme) {
    final filteredDocuments = _filteredDocuments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quản lý tài liệu nguồn',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Quản lý và cập nhật kho tri thức cho hệ thống AI RAG.',
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        _buildStatistics(theme),

        const SizedBox(height: 28),

        _buildSectionTitle(
          icon: Icons.cloud_upload_outlined,
          title: 'Tải tài liệu lên',
        ),
        const SizedBox(height: 14),

        DocumentUploadSection(
          isUploading: _isUploading,
          selectedFileName: _selectedFileName,
          onUpload: _pickAndUploadFile,
        ),

        if (_uploadResult != null) ...[
          const SizedBox(height: 20),
          UploadResultCard(result: _uploadResult!),
        ],

        const SizedBox(height: 32),

        _buildSectionTitle(
          icon: Icons.folder_open_outlined,
          title: 'Danh sách tài liệu',
          trailing: Text(
            '${_documents.length} tài liệu',
            style: const TextStyle(
              color: purple,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 14),

        DocumentSearchBar(
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),

        const SizedBox(height: 18),

        DocumentList(
          documents: filteredDocuments,
          isLoading: _isLoadingDocuments,
          onDelete: _deleteDocument,
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildStatistics(ThemeData theme) {
    final processedCount = _documents.where((document) {
      return document['status']?.toString() == 'processed';
    }).length;

    final otherCount = _documents.length - processedCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          _statCard(
            icon: Icons.folder_outlined,
            title: 'Tổng tài liệu',
            value: '${_documents.length}',
            color: purple,
            theme: theme,
          ),
          _statCard(
            icon: Icons.check_circle_outline,
            title: 'Đã xử lý',
            value: '$processedCount',
            color: Colors.green,
            theme: theme,
          ),
          _statCard(
            icon: Icons.pending_outlined,
            title: 'Chưa xử lý / lỗi',
            value: '$otherCount',
            color: Colors.orange,
            theme: theme,
          ),
        ];

        if (constraints.maxWidth < 550) {
          return Column(
            children: cards.map((card) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: card,
              );
            }).toList(),
          );
        }

        return Row(
          children: cards.map((card) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: card,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: purple, size: 22),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
