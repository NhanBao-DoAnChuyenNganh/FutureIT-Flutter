import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import 'auth/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// 🔹 Load thông tin user từ SharedPreferences
  Future<Map<String, dynamic>> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'role': prefs.getString('role') ?? 'Unknown',
      'username': prefs.getString('username') ?? 'Người dùng',
      'email': prefs.getString('email') ?? '',
      'sdt': prefs.getString('sdt') ?? '',
      'diaChi': prefs.getString('diaChi') ?? '',
      'avatarBase64': prefs.getString('avatarBase64') ?? '',
    };
  }

  /// 🚪 Đăng xuất
  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadUserInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Text(
                'Lỗi tải thông tin: ${snapshot.error ?? 'Không có dữ liệu'}',
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final role = data['role'] as String;
        final username = data['username'] as String;
        final email = data['email'] as String;
        final sdt = data['sdt'] as String;
        final diaChi = data['diaChi'] as String;
        final avatarBase64 = data['avatarBase64'] as String?;

        // 🖼️ Xử lý avatar
        ImageProvider avatarImage;
        if (avatarBase64 != null && avatarBase64.isNotEmpty) {
          try {
            avatarImage = MemoryImage(base64Decode(avatarBase64.split(',').last));
          } catch (_) {
            avatarImage = const AssetImage('assets/avatar.png');
          }
        } else {
          avatarImage = const AssetImage('assets/avatar.png');
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Row(
              children: [
                CircleAvatar(radius: 18, backgroundImage: avatarImage),
                const SizedBox(width: 10),
                Text(
                  username,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                          email: email,
                          username: username,
                          sdt: sdt,
                          diaChi: diaChi,
                          avatarBase64: avatarBase64,
                        ),
                      ),
                    );
                  } else if (value == 'logout') {
                    await _logout(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('Hồ sơ cá nhân'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Đăng xuất'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 50, backgroundImage: avatarImage),
                const SizedBox(height: 10),
                Text(
                  'Xin chào, $username!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Vai trò: $role',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
