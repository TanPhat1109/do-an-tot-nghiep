import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isRegister = false;

  static const Color purple = Color(0xFF5945ED);
  static const Color darkText = Color(0xFF172033);
  static const Color subText = Color(0xFF71829F);

  void _switchTab(bool register) {
    setState(() {
      isRegister = register;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 42),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE3E9F2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5945ED), Color(0xFF8138ED)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: purple.withValues(alpha: 0.25),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'NexusRAG AI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    isRegister
                        ? 'Tạo tài khoản Trợ lý Tri thức Doanh nghiệp'
                        : 'Đăng nhập vào Trợ lý Tri thức Doanh nghiệp',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: subText),
                  ),

                  const SizedBox(height: 34),

                  // Hai tab
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3F8),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Row(
                      children: [
                        _buildTab(
                          '1. Đăng nhập',
                          !isRegister,
                          () => _switchTab(false),
                        ),
                        _buildTab(
                          '2. Đăng ký',
                          isRegister,
                          () => _switchTab(true),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Nội dung từng tab
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isRegister
                        ? RegisterScreen(
                            key: const ValueKey('register'),
                            onRegistered: () {
                              _switchTab(false);
                            },
                          )
                        : const LoginScreen(key: ValueKey('login')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? darkText : subText,
                fontSize: 16,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
