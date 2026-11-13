import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../../../config/api_config.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../auth/screens/auth_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthRepository _authRepo = AuthRepository();

  bool _isUploading = false;
  String? _selectedFileName;
  Map<String, dynamic>? _uploadResult;

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
      // 1. Chọn file
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

      // 2. Kiểm tra dung lượng
      if (file.size > 10 * 1024 * 1024) {
        _showMessage('File không được vượt quá 10 MB!', isError: true);
        return;
      }

      setState(() {
        _selectedFileName = file.name;
        _isUploading = true;
        _uploadResult = null;
      });

      // 3. Lấy JWT token
      final token = await _authRepo.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.');
      }

      // 4. Tạo request upload
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/documents/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
      );

      // 5. Gửi file lên FastAPI
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 3),
      );

      final response = await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _uploadResult = data;
        });

        _showMessage('Upload tài liệu thành công!');
      } else {
        throw Exception(data['detail'] ?? 'Upload thất bại');
      }
    } catch (e) {
      _showMessage('Lỗi: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ADMIN DASHBOARD',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xin chào, Admin!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Quản lý tài liệu cho hệ thống hỏi đáp RAG',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Khu vực upload
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 64,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'TẢI TÀI LIỆU LÊN HỆ THỐNG',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Chọn tài liệu PDF, DOCX hoặc TXT để đưa vào hệ thống RAG.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Dung lượng tối đa: 10 MB',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 20),

                        if (_selectedFileName != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _selectedFileName!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isUploading ? null : _pickAndUploadFile,
                            icon: _isUploading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.upload_file),
                            label: Text(
                              _isUploading
                                  ? 'ĐANG UPLOAD VÀ XỬ LÝ...'
                                  : 'CHỌN FILE VÀ UPLOAD',
                            ),
                          ),
                        ),

                        if (_isUploading) ...[
                          const SizedBox(height: 16),
                          const LinearProgressIndicator(),
                          const SizedBox(height: 8),
                          const Text(
                            'Đang lưu tài liệu, tạo chunks và embedding. Vui lòng chờ...',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Kết quả upload
                if (_uploadResult != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    color: Colors.green.withValues(alpha: .06),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'XỬ LÝ THÀNH CÔNG',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          _ResultRow(
                            title: 'Tên tài liệu',
                            value: '${_uploadResult!['original_filename']}',
                          ),
                          _ResultRow(
                            title: 'Document ID',
                            value: '${_uploadResult!['document_id']}',
                          ),
                          _ResultRow(
                            title: 'Số chunks',
                            value: '${_uploadResult!['total_chunks']}',
                          ),
                          _ResultRow(
                            title: 'Trạng thái',
                            value: '${_uploadResult!['status']}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_uploadResult!['message'] ?? ''}',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String title;
  final String value;

  const _ResultRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
