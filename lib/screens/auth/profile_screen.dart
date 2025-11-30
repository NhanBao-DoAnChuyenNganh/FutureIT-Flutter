import 'dart:convert';
import 'dart:io';
import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
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

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => avatarFile = File(picked.path));
    }
  }

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

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, {bool enabled = true}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: enabled ? const Color(0xFF1565C0) : Colors.grey),
      filled: true,
      fillColor: enabled ? const Color(0xFFF5F9FF) : Colors.grey.shade100,
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
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }


  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;
    if (avatarFile != null) {
      avatarImage = FileImage(avatarFile!);
    } else if (avatarBase64 != null && avatarBase64!.isNotEmpty) {
      try {
        avatarImage = MemoryImage(base64Decode(avatarBase64!.split(',').last));
      } catch (_) {}
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E88E5), Color(0xFF5E35B1), Color(0xFF7B1FA2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Hồ sơ cá nhân',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Avatar Section
              GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: avatarImage != null
                            ? Image(image: avatarImage, fit: BoxFit.cover, width: 120, height: 120)
                            : Container(
                                color: Colors.white,
                                child: const Icon(Icons.person, size: 60, color: Color(0xFF1565C0)),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Color(0xFF1565C0)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hoTen.text.isNotEmpty ? hoTen.text : 'Người dùng',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                email.text,
                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 20),
              // Form Section
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông tin cá nhân',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Email (disabled)
                        TextField(
                          controller: email,
                          enabled: false,
                          decoration: _buildInputDecoration('Email', Icons.email_outlined, enabled: false),
                        ),
                        const SizedBox(height: 14),
                        // Ngày đăng ký (disabled)
                        TextField(
                          controller: TextEditingController(text: _ngayDK ?? ''),
                          enabled: false,
                          decoration: _buildInputDecoration('Ngày đăng ký', Icons.calendar_today_outlined, enabled: false),
                        ),
                        const SizedBox(height: 14),
                        // Họ và tên
                        TextField(
                          controller: hoTen,
                          decoration: _buildInputDecoration('Họ và tên', Icons.person_outline),
                        ),
                        const SizedBox(height: 14),
                        // Số điện thoại
                        TextField(
                          controller: sdt,
                          keyboardType: TextInputType.phone,
                          decoration: _buildInputDecoration('Số điện thoại', Icons.phone_outlined),
                        ),
                        const SizedBox(height: 14),
                        // Địa chỉ
                        TextField(
                          controller: diaChi,
                          decoration: _buildInputDecoration('Địa chỉ', Icons.location_on_outlined),
                        ),
                        const SizedBox(height: 28),
                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1565C0)))
                              : ElevatedButton.icon(
                                  onPressed: _updateProfile,
                                  icon: const Icon(Icons.save_rounded),
                                  label: const Text('Lưu thay đổi', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1565C0),
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shadowColor: const Color(0xFF1565C0).withOpacity(0.4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                      ],
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
