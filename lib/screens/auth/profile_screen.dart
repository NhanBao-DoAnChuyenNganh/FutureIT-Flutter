import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final String? email;
  final String? username;
  final String? sdt;
  final String? diaChi;
  final String? avatarBase64;
  final String? ngayDK;

  const ProfileScreen({
    super.key,
    this.email,
    this.username,
    this.sdt,
    this.diaChi,
    this.avatarBase64,
    this.ngayDK,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController hoTen = TextEditingController();
  final TextEditingController sdt = TextEditingController();
  final TextEditingController diaChi = TextEditingController();

  File? avatarFile;
  String? avatarBase64;
  String? _ngayDK;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// 🔹 Load dữ liệu user từ SharedPreferences hoặc widget
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email.text = widget.email ?? prefs.getString('email') ?? '';
      hoTen.text = widget.username ?? prefs.getString('username') ?? '';
      sdt.text = widget.sdt ?? prefs.getString('sdt') ?? '';
      diaChi.text = widget.diaChi ?? prefs.getString('diaChi') ?? '';
      avatarBase64 = widget.avatarBase64 ?? prefs.getString('avatarBase64');
      _ngayDK = widget.ngayDK ?? prefs.getString('ngayDK') ?? '';
    });
  }

  /// 🔹 Chọn avatar từ gallery
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => avatarFile = File(picked.path));
    }
  }

  /// 🔹 Cập nhật thông tin hồ sơ
  Future<void> _updateProfile() async {
    setState(() => isLoading = true);

    final result = await AuthService.updateProfile(
      email: email.text,
      hoTen: hoTen.text,
      sdt: sdt.text,
      diaChi: diaChi.text,
      avatar: avatarFile,
    );

    setState(() => isLoading = false);

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ ${result['error']}')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('✅ Cập nhật thành công!')));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', hoTen.text);
      await prefs.setString('sdt', sdt.text);
      await prefs.setString('diaChi', diaChi.text);

      if (avatarFile != null) {
        final bytes = await avatarFile!.readAsBytes();
        await prefs.setString(
            'avatarBase64', 'data:image/png;base64,${base64Encode(bytes)}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🖼️ Xử lý avatar hiển thị
    ImageProvider? avatarImage;
    if (avatarFile != null) {
      avatarImage = FileImage(avatarFile!);
    } else if (avatarBase64 != null && avatarBase64!.isNotEmpty) {
      try {
        avatarImage = MemoryImage(base64Decode(avatarBase64!.split(',').last));
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật hồ sơ'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: _pickAvatar,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Email (không chỉnh sửa)
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
              enabled: false,
            ),
            const SizedBox(height: 10),

            // Ngày đăng ký (chỉ hiển thị)
            TextField(
              controller: TextEditingController(text: _ngayDK ?? ''),
              decoration: const InputDecoration(labelText: 'Ngày đăng ký'),
              enabled: false,
            ),
            const SizedBox(height: 10),

            // Họ và tên
            TextField(
              controller: hoTen,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            const SizedBox(height: 10),

            // Số điện thoại
            TextField(
              controller: sdt,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
            const SizedBox(height: 10),

            // Địa chỉ
            TextField(
              controller: diaChi,
              decoration: const InputDecoration(labelText: 'Địa chỉ'),
            ),
            const SizedBox(height: 20),

            // Nút lưu thay đổi
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Lưu thay đổi',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
