import 'package:flutter/material.dart';
import '../student/khoa_hoc_da_dang_ky_screen.dart';
import '../student/student_home_screen.dart';
import '../student/khoa_hoc_list_screen.dart';
import '../student/about_screen.dart';
import '../student/tin_tuc_tuyen_dung_screen.dart';
import '../student/danh_sach_quan_tam_screen.dart';
import '../student/teacher_list_screen.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    StudentHomeScreen(),
    AboutScreen(),
    KhoaHocListScreen(),
    TinTucScreen(),
    TeacherListScreen(),
    KhoaHocDaDangKyScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          // Nếu người dùng chọn tab "Học Tập" (index = 5)
          if (index == 5) {
            bool loggedIn = await AuthService.isLoggedIn();
            if (!loggedIn) {
              // Hiển thị dialog thông báo chưa đăng nhập
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Thông báo'),
                  content: const Text('Bạn chưa đăng nhập. Vui lòng đăng nhập để tiếp tục.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Hủy
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Đóng dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      child: const Text('Đăng nhập'),
                    ),
                  ],
                ),
              );
              return; // Không đổi tab
            }
          }

          // Nếu đã đăng nhập hoặc tab khác, đổi tab bình thường
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'Về chúng tôi'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Khóa học'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Tin tức tuyển dụng'),
          BottomNavigationBarItem(icon: Icon(Icons.cast_for_education), label: 'Giáo viên'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Học Tập'),
        ],
      ),
    );
  }
}
