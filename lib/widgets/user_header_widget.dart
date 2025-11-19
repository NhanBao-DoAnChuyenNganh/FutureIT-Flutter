import 'dart:convert';
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/profile_screen.dart';

class UserAppBarWidget extends StatelessWidget {
  final String username;
  final String email;
  final String sdt;
  final String diaChi;
  final String avatarBase64;
  final VoidCallback onLogout;

  const UserAppBarWidget({
    super.key,
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
        final pureBase64 = avatarBase64.contains(',')
            ? avatarBase64.split(',').last
            : avatarBase64;
        final bytes = base64Decode(pureBase64);
        return MemoryImage(bytes);
      }
    } catch (_) {}
    return const AssetImage('assets/avatar.png');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 18, backgroundImage: avatarImage),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            username,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          ),
        ),
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
    );
  }
}
