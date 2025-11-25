import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/teacher.dart';
import '../../services/khoa_hoc_student_service.dart';
import '../../widgets/user_header_widget.dart';
import '../auth/login_screen.dart';
import '../../services/auth_service.dart';

class TeacherListScreen extends StatefulWidget {
  const TeacherListScreen({super.key});

  @override
  State<TeacherListScreen> createState() => _TeacherListScreenState();
}

class _TeacherListScreenState extends State<TeacherListScreen> {
  late Future<List<Teacher>> _futureTeachers;
  Map<String, String> userData = {};
  String avatarBase64 = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _futureTeachers = _loadTeachers();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    userData = {
      'username': prefs.getString('username') ?? 'Người dùng',
      'email': prefs.getString('email') ?? '',
      'sdt': prefs.getString('sdt') ?? '',
      'diaChi': prefs.getString('diaChi') ?? '',
      'avatarBase64': prefs.getString('avatarBase64') ?? '',
    };
    avatarBase64 = userData['avatarBase64'] ?? '';
    setState(() {});
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  Future<void> saveTeachersCache(List<Teacher> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cache_teachers', jsonEncode(data.map((e) => e.toJson()).toList()));
    prefs.setInt('cache_time_teachers', DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<Teacher>?> loadTeachersCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cache_teachers');
    if (jsonString == null) return null;
    final decoded = jsonDecode(jsonString) as List;
    return decoded.map((e) => Teacher.fromJson(e)).toList();
  }

  Future<bool> isTeachersCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('cache_time_teachers') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const cacheLimit = 30 * 60 * 1000; // 30 phút
    return (now - savedTime) > cacheLimit;
  }

  Future<List<Teacher>> _loadTeachers() async {
    final cache = await loadTeachersCache();
    final expired = await isTeachersCacheExpired();

    if (cache != null && !expired) return cache;

    try {
      final apiData = await KhoaHocService.getTeachers();
      if (apiData.isNotEmpty) await saveTeachersCache(apiData);
      return apiData;
    } catch (e) {
      print("Lỗi API: $e");
      if (cache != null) return cache;
      throw Exception("Không thể tải danh sách giáo viên");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: UserAppBarWidget(
          username: userData['username'] ?? 'Người dùng',
          email: userData['email'] ?? '',
          sdt: userData['sdt'] ?? '',
          diaChi: userData['diaChi'] ?? '',
          avatarBase64: avatarBase64,
          onLogout: _logout,
        ),
      ),
      body: FutureBuilder<List<Teacher>>(
        future: _futureTeachers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Chưa có giáo viên'));
          }

          final teachers = snapshot.data!;
          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final t = teachers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(t.avatar),
                ),
                title: Text(t.hoTen),
                subtitle: Text(t.chuyenNganh),
                trailing: Text(t.diaChi),
              );
            },
          );
        },
      ),
    );
  }
}
