import 'dart:io';
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

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => avatar = File(picked.path));
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await AuthService.register(
      hoTen: hoTen.text,
      sdt: sdt.text,
      diaChi: diaChi.text,
      email: email.text,
      password: password.text,
      role: selectedRole,
      avatarPath: avatar?.path ?? '',
    );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6EFFF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tạo tài khoản mới',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundImage:
                        avatar != null ? FileImage(avatar!) : null,
                        child: avatar == null
                            ? const Icon(Icons.camera_alt, size: 40)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: hoTen,
                      decoration: const InputDecoration(labelText: 'Họ và tên'),
                      validator: (v) => v!.isEmpty ? 'Nhập họ tên' : null,
                    ),
                    TextFormField(
                      controller: email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) => v!.isEmpty ? 'Nhập email' : null,
                    ),
                    TextFormField(
                      controller: sdt,
                      decoration:
                      const InputDecoration(labelText: 'Số điện thoại'),
                    ),
                    TextFormField(
                      controller: diaChi,
                      decoration:
                      const InputDecoration(labelText: 'Địa chỉ'),
                    ),
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      decoration:
                      const InputDecoration(labelText: 'Mật khẩu'),
                      validator: (v) =>
                      v!.length < 6 ? 'Mật khẩu ít nhất 6 ký tự' : null,
                    ),
                    TextFormField(
                      controller: confirmPassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Xác nhận mật khẩu'),
                      validator: (v) =>
                      v != password.text ? 'Mật khẩu không khớp' : null,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Chọn role'),
                      value: selectedRole,
                      items: const [
                        DropdownMenuItem(
                            value: 'Student', child: Text('Student')),
                        DropdownMenuItem(
                            value: 'Teacher', child: Text('Teacher')),
                        DropdownMenuItem(value: 'Staff', child: Text('Staff')),
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                      ],
                      onChanged: (v) => setState(() => selectedRole = v!),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Đăng ký',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Đã có tài khoản? Đăng nhập'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
