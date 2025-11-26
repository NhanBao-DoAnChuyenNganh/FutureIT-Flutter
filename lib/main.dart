import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
import 'package:do_an_chuyen_nganh/screens/student/khoa_hoc_list_screen.dart';
import 'package:do_an_chuyen_nganh/screens/student/student_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/HomeScreen.dart';
import 'services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<Widget> _getStartScreen() async {
    //final getRole =  await AuthService.getRole();
    //final isLoggedIn = await AuthService.isLoggedIn();
    //if (isLoggedIn ) {
      return const DashboardScreen();
    // else {
      //return const LoginScreen();
    //}
    //return const StudentHomeScreen();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đồ án chuyên ngành',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
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
