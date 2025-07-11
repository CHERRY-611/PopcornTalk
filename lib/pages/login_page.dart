import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import '../widgets/splash_overlay.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  final String baseUrl = 'http://10.0.2.2:8000/api';

  void _handleLogin() async {
    final id = _idController.text.trim();
    final pw = _pwController.text.trim();

      if (id.isEmpty || pw.isEmpty) {
      _showError('ID와 Password를 입력해주세요');
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': id, 'password': pw}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      final user = data['user'];

      // SecureStorage에 토큰 저장
      final storage = FlutterSecureStorage();
      await storage.write(key: 'access_token', value: token);

      // 홈 페이지 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Stack(
            children: [
              HomePage(
                username: user['username'],
                nickname: user['nickname'],
                profileImageUrl: user['profile_image'],
              ),
              const SplashOverlay(duration: Duration(milliseconds: 2500)),
            ],
          ),
        ),
      );
    } else {
      _showError('로그인 실패');
    }
  }

  void _handleSignup() async {
    final id = _idController.text.trim();
    final pw = _pwController.text.trim();

    if (id.isEmpty || pw.isEmpty) {
      _showError('ID와 Password를 입력해주세요');
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': id,
        'password': pw,
        'nickname': id, 
        'profile_image_url': null, 
      }),
    );

    if (response.statusCode == 200) {
      _showError('회원가입 성공! 이제 로그인하세요.');
    } else {
      _showError('회원가입 실패');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text(
                '로그인',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0C141C),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  hintText: '아이디',
                  filled: true,
                  fillColor: const Color(0xFFE8EDF4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _pwController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  filled: true,
                  fillColor: const Color(0xFFE8EDF4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE66161),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _handleSignup,
                  child: const Text(
                    '계정 만들기',
                    style: TextStyle(
                      color: Color(0xFF636E79),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
