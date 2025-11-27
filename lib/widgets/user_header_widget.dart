import 'dart:convert';
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/profile_screen.dart';

class UserAppBarWidget extends StatelessWidget {
  final bool isLoggedIn;
  final String username;
  final String email;
  final String sdt;
  final String diaChi;
  final String avatarBase64;
  final VoidCallback onLogout;

  const UserAppBarWidget({
    super.key,
    required this.isLoggedIn,
    required this.username,
    required this.email,
    required this.sdt,
    required this.diaChi,
    required this.avatarBase64,
    required this.onLogout,
  });

  ImageProvider get avatarImage {
    try {
      if (avatarBase64.isNotEmpty) {
        final pure = avatarBase64.contains(',')
            ? avatarBase64.split(',').last
            : avatarBase64;
        return MemoryImage(base64Decode(pure));
      }
    } catch (_) {}
    return const AssetImage('assets/avatar.png');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 🔹 BÊN TRÁI: Tên app
        const Text(
          "FutureIT",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const Spacer(),

        // 🔹 NẾU CHƯA ĐĂNG NHẬP → Hiện Đăng nhập / Đăng ký
        if (!isLoggedIn) ...[
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("Đăng nhập"),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            child: const Text("Đăng ký"),
          ),
        ]

        // 🔹 NẾU ĐÃ ĐĂNG NHẬP → Avatar + Menu
        else ...[
          CircleAvatar(radius: 18, backgroundImage: avatarImage),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
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
                onLogout();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('Hồ sơ cá nhân')),
              PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
            ],
          ),
        ],
      ],
    );
  }
}
