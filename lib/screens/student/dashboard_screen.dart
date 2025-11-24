
import 'package:flutter/material.dart';
import '../student/student_home.dart';
import '../student/about_screen.dart';
import '../student/tin_tuc_tuyen_dung_screen.dart';
import '../student/danh_sach_quan_tam_screen.dart';
import '../student/teacher_list_screen.dart';
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
    TinTucScreen(),
    DanhSachQuanTamScreen(),
    TeacherScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() => _currentIndex = index);
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Về chúng tôi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Tin tức tuyển dụng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Quan tâm',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.cast_for_education),
              label: 'Giáo viên'),
        ],
      ),
    );
  }
}
