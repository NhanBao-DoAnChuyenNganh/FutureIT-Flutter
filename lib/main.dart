import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
import 'package:do_an_chuyen_nganh/screens/student/khoa_hoc_list_screen.dart';
import 'package:do_an_chuyen_nganh/screens/student/student_home_screen.dart';
import 'package:do_an_chuyen_nganh/screens/teacher/teacher_home_screen.dart';
import 'package:do_an_chuyen_nganh/services/deep_link_service.dart';
import 'package:do_an_chuyen_nganh/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/HomeScreen.dart';
import 'services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  // Khởi tạo DeepLinkService để nhận callback từ Momo/ZaloPay
  await DeepLinkService().init();
  
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<Widget> _getStartScreen() async {
    final getRole = await AuthService.getRole();
    final isLoggedIn = await AuthService.isLoggedIn();

    if (isLoggedIn) {
      if (getRole == "Student") {
        return const DashboardScreen(); // màn hình cho Student
      } else if (getRole == "Teacher") {
        return const TeacherHomeScreen(); // màn hình cho Teacher
      } else {

        return const DashboardScreen();
      }
    } else {
      return const DashboardScreen(); // nếu chưa đăng nhập
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đồ án chuyên ngành',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder<Widget>(
        future: _getStartScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Lỗi khởi tạo ứng dụng')),
            );
          }
          return snapshot.data!;
        },
      ),
    );
  }
}
