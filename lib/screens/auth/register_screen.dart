import 'dart:io';
import 'package:do_an_chuyen_nganh/screens/auth/login_screen.dart';
import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController hoTen = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController sdt = TextEditingController();
  final TextEditingController diaChi = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  String selectedRole = 'Student';
  File? avatar;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool isLoading = false;

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => avatar = File(picked.path));
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final result = await AuthService.register(
      hoTen: hoTen.text,
      sdt: sdt.text,
      diaChi: diaChi.text,
      email: email.text,
      password: password.text,
      role: selectedRole,
      avatarPath: avatar?.path ?? '',
    );

    setState(() => isLoading = false);

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ${result['error']}')),
      );
    } else {
      final bool isApproved = result['isApproved'] ?? true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isApproved
              ? 'Đăng ký thành công! Bạn có thể đăng nhập ngay'
              : 'Đăng ký thành công! Hãy chờ admin duyệt bạn'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  InputDecoration _buildInputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      // Header
                  const Icon(Icons.person_add_rounded, size: 60, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Tạo tài khoản mới',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Điền thông tin để bắt đầu học tập',
                    style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 30),
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
                          // Avatar Picker
                          GestureDetector(
                            onTap: _pickAvatar,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF1565C0).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: avatar != null
                                      ? ClipOval(
                                          child: Image.file(avatar!, fit: BoxFit.cover, width: 100, height: 100),
                                        )
                                      : const Icon(Icons.person, size: 50, color: Colors.white),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1565C0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Chọn ảnh đại diện', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          const SizedBox(height: 20),
                          // Form Fields
                          TextFormField(
                            controller: hoTen,
                            decoration: _buildInputDecoration('Họ và tên', 'Nhập họ và tên', Icons.person_outline),
                            validator: (v) => v!.isEmpty ? 'Nhập họ tên' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _buildInputDecoration('Email', 'Nhập email', Icons.email_outlined),
                            validator: (v) => v!.isEmpty ? 'Nhập email' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: sdt,
                            keyboardType: TextInputType.phone,
                            decoration: _buildInputDecoration('Số điện thoại', 'Nhập số điện thoại', Icons.phone_outlined),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: diaChi,
                            decoration: _buildInputDecoration('Địa chỉ', 'Nhập địa chỉ', Icons.location_on_outlined),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: password,
                            obscureText: _obscurePassword,
                            decoration: _buildInputDecoration('Mật khẩu', 'Nhập mật khẩu', Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) => v!.length < 6 ? 'Mật khẩu ít nhất 6 ký tự' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: confirmPassword,
                            obscureText: _obscureConfirm,
                            decoration: _buildInputDecoration('Xác nhận mật khẩu', 'Nhập lại mật khẩu', Icons.lock_outline).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) => v != password.text ? 'Mật khẩu không khớp' : null,
                          ),
                          const SizedBox(height: 14),
                          // Role Dropdown
                          DropdownButtonFormField<String>(
                            decoration: _buildInputDecoration('Vai trò', '', Icons.school_outlined),
                            value: selectedRole,
                            items: const [
                              DropdownMenuItem(value: 'Student', child: Text('Học viên')),
                              DropdownMenuItem(value: 'Teacher', child: Text('Giảng viên')),
                            ],
                            onChanged: (v) => setState(() => selectedRole = v!),
                          ),
                          const SizedBox(height: 24),
                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: isLoading
                                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
                                : ElevatedButton(
                                    onPressed: _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1565C0),
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      shadowColor: const Color(0xFF1565C0).withOpacity(0.4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: const Text('Đăng ký', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Đã có tài khoản? ', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15)),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: const Text(
                          'Đăng nhập',
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
