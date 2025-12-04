import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
import 'package:do_an_chuyen_nganh/screens/teacher/teacher_home_screen.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../HomeScreen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Hãy chờ admin duyệt bạn'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final result = await AuthService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' ${result['error']}')),
      );
      return;
    }

    final bool isApproved = result['isApproved'] ?? true;
    if (!isApproved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hãy chờ admin duyệt bạn'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final role = (result['roles'] != null && result['roles'].isNotEmpty)
        ? result['roles'][0]
        : 'User';

    Widget nextScreen;
    switch (role) {
      case 'Student':
        nextScreen = DashboardScreen();
        break;
      case 'Teacher':
        nextScreen = TeacherHomeScreen();
        break;
      default:
        nextScreen = const HomeScreen();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E88E5),
              Color(0xFF5E35B1),
              Color(0xFF7B1FA2),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back Button
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    (route) => false,
                  ),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chào mừng trở lại!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đăng nhập để tiếp tục học tập',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email Field
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Nhập email của bạn',
                              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1565C0)),
                              filled: true,
                              fillColor: const Color(0xFFF5F9FF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
                              ),
                            ),
                            validator: (v) => v!.isEmpty ? 'Vui lòng nhập email' : null,
                          ),
                          const SizedBox(height: 16),
                          // Password Field
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              hintText: 'Nhập mật khẩu',
                              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1565C0)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F9FF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
                              ),
                            ),
                            validator: (v) => v!.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
                          ),
                          const SizedBox(height: 24),
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: isLoading
                                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
                                : ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1565C0),
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      shadowColor: const Color(0xFF1565C0).withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Đăng nhập',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chưa có tài khoản? ',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                          if (result == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Hãy chờ admin duyệt bạn'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
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
