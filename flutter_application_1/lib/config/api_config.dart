class ApiConfig {
  // Đổi thành IP máy tính nếu test trên điện thoại thật (vd: http://192.168.1.X:8000)
  static const String baseUrl = 'http://127.0.0.1:8000';

  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String me = '$baseUrl/auth/me';
}
