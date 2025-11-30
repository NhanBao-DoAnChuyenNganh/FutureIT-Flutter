import 'dart:convert';
import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/teacher.dart';
import '../../services/khoa_hoc_student_service.dart';
import '../../widgets/user_header_widget.dart';
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
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _futureTeachers = _loadTeachers();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    isLoggedIn = token != null && token.isNotEmpty;
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
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
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
    const cacheLimit = 30 * 60 * 1000;
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
      if (cache != null) return cache;
      throw Exception("Không thể tải danh sách giáo viên");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF7B1FA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: UserAppBarWidget(
          isLoggedIn: isLoggedIn,
          username: userData['username'] ?? '',
          email: userData['email'] ?? '',
          sdt: userData['sdt'] ?? '',
          diaChi: userData['diaChi'] ?? '',
          avatarBase64: avatarBase64,
          onLogout: _logout,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đội ngũ giảng viên',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Những giảng viên giàu kinh nghiệm',
                  style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          // Teacher List
          Expanded(
            child: FutureBuilder<List<Teacher>>(
              future: _futureTeachers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF5E35B1)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Chưa có giáo viên'));
                }
                final teachers = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: teachers.length,
                  itemBuilder: (context, index) => _buildTeacherCard(teachers[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTeacherCard(Teacher teacher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF7B1FA2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5E35B1).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  teacher.avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher.hoTen,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFF1E88E5).withOpacity(0.15), const Color(0xFF7B1FA2).withOpacity(0.15)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          teacher.chuyenNganh,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF5E35B1), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          teacher.diaChi,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF5E35B1)),
            ),
          ],
        ),
      ),
    );
  }
}
