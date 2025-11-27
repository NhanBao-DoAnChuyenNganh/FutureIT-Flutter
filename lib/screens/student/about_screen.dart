import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
import 'package:do_an_chuyen_nganh/screens/student/student_home_screen.dart';
import 'package:flutter/material.dart';
import '../../widgets/user_header_widget.dart';
import '../auth/login_screen.dart';
import '../auth/profile_screen.dart';
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Map<String, String> userData = {};
  String avatarBase64 = '';
  bool isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    isLoggedIn = token != null && token.isNotEmpty;

    userData = {
      'username': prefs.getString('username') ?? '',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: UserAppBarWidget(
          isLoggedIn: isLoggedIn,           // 🔥 Truyền trạng thái đăng nhập
          username: userData['username'] ?? '',
          email: userData['email'] ?? '',
          sdt: userData['sdt'] ?? '',
          diaChi: userData['diaChi'] ?? '',
          avatarBase64: avatarBase64,
          onLogout: _logout,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                "VỀ CHÚNG TÔI",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            // Mission
            Text(
              "Nhiệm vụ của chúng tôi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Chúng tôi cam kết mang đến sự hài lòng, chất lượng và sự tận tâm trong từng dịch vụ.",
            ),
            const SizedBox(height: 5),
            Text(
              "Với đội ngũ chuyên nghiệp và giải pháp hiệu quả, chúng tôi luôn đổi mới để mang lại kết quả tốt nhất.",
            ),
            const SizedBox(height: 20),
            // Goal
            Text(
              "Mục tiêu của chúng tôi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Chúng tôi hướng đến môi trường học tập hiện đại và chất lượng, đem lại giá trị bền vững cho cộng đồng.",
            ),
            const SizedBox(height: 30),
            // Section 2
            Text(
              "Bạn Muốn Hiểu Rõ Hơn?",
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Có rất nhiều cách phát triển khác nhau, nhưng chúng tôi luôn kết hợp sự sáng tạo với giá trị cốt lõi.",
            ),
            const SizedBox(height: 15),
            // Bullets
            Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.lightbulb),
                  title: Text("Nền tảng ý tưởng sáng tạo"),
                ),
                ListTile(
                  leading: Icon(Icons.school),
                  title: Text("Phương pháp giảng dạy dễ tiếp cận"),
                ),
                ListTile(
                  leading: Icon(Icons.update),
                  title: Text("Chương trình học luôn cập nhật"),
                ),
                ListTile(
                  leading: Icon(Icons.build),
                  title: Text("Kiến thức thực tiễn và công cụ hiện đại"),
                ),
              ],
            ),
            const SizedBox(height: 40),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'lib/image/KH2c.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
