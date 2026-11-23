import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegistered;

  const RegisterScreen({super.key, required this.onRegistered});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepo = AuthRepository();

  bool _isLoading = false;
  bool _obscurePassword = true;

  static const Color _purple = Color(0xFF5945ED);
  static const Color _borderColor = Color(0xFFDDE5F0);

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authRepo.register(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Đăng ký tài khoản thành công! Vui lòng đăng nhập.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Trả kết quả thành công về AuthScreen.
      widget.onRegistered();
    } catch (e) {
      if (!mounted) return;

      String errorMsg = e.toString().replaceAll('Exception: ', '');

      if (errorMsg.contains('at least 8 characters') ||
          errorMsg.contains('string_too_short')) {
        errorMsg = 'Mật khẩu phải chứa ít nhất 8 ký tự!';
      } else if (errorMsg.contains('Failed to fetch')) {
        errorMsg = 'Không thể kết nối đến Server FastAPI!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ $errorMsg'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _decoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9AA9BF), fontSize: 15),
      prefixIcon: Icon(icon, color: const Color(0xFF91A3BD)),
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _purple, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Họ và tên',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF34435C),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _fullNameController,
            textCapitalization: TextCapitalization.words,
            decoration: _decoration(
              hint: 'Nhập họ và tên',
              icon: Icons.person_outline,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ tên';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          const Text(
            'Email công việc',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF34435C),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _decoration(
              hint: 'Nhập email của bạn',
              icon: Icons.mail_outline,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          const Text(
            'Mật khẩu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF34435C),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration:
                _decoration(
                  hint: 'Tạo mật khẩu (ít nhất 8 ký tự)',
                  icon: Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF91A3BD),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Mật khẩu tối thiểu 8 ký tự';
              }
              return null;
            },
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5144E9), Color(0xFF8138ED)],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _purple.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'TẠO TÀI KHOẢN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward, size: 21),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
