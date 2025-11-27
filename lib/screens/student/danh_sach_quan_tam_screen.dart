import 'dart:convert';
import 'package:do_an_chuyen_nganh/screens/auth/login_screen.dart';
import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
import 'package:do_an_chuyen_nganh/screens/student/student_home_screen.dart';
import 'package:do_an_chuyen_nganh/services/auth_service.dart';
import 'package:do_an_chuyen_nganh/widgets/user_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/khoa_hoc.dart';
import '../../services/khoa_hoc_student_service.dart';
import '../../widgets/khoa_hoc_card.dart';

class DanhSachQuanTamScreen extends StatefulWidget {
  const DanhSachQuanTamScreen({super.key});

  @override
  State<DanhSachQuanTamScreen> createState() => _DanhSachQuanTamScreenState();
}

class _DanhSachQuanTamScreenState extends State<DanhSachQuanTamScreen> {
  List<KhoaHoc> listQuanTam = [];
  bool loading = true;
  Map<String, String> userData = {};
  String avatarBase64 = '';
  bool isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDanhSachQuanTam();
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

  Future<void> saveQuanTamCache(List<KhoaHoc> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'cache_quan_tam', jsonEncode(data.map((e) => e.toJson()).toList()));
    prefs.setInt('cache_time_quan_tam', DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<KhoaHoc>?> loadQuanTamCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cache_quan_tam');
    if (jsonString == null) return null;
    final decoded = jsonDecode(jsonString);
    return List<KhoaHoc>.from(decoded.map((e) => KhoaHoc.fromJson(e)));
  }

  Future<bool> isQuanTamCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('cache_time_quan_tam') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - savedTime) > (30 * 60 * 1000); // 30 phút
  }

  Future<void> _loadDanhSachQuanTam() async {
    setState(() => loading = true);

    // Load cache
    final cache = await loadQuanTamCache();
    final expired = await isQuanTamCacheExpired();
    if (cache != null && !expired) {
      listQuanTam = cache;
      setState(() => loading = false);
    }

    try {
      // Gọi API lấy danh sách quan tâm
      final basicList = await KhoaHocService.getDanhSachQuanTam();

      // Gọi API chi tiết cho từng khóa học
      final List<KhoaHoc> fullList = [];
      for (var kh in basicList) {
        try {
          final chiTiet = await KhoaHocService.getChiTietKhoaHoc(kh.maKhoaHoc);
          fullList.add(KhoaHoc(
            maKhoaHoc: kh.maKhoaHoc,
            tenKhoaHoc: kh.tenKhoaHoc,
            ngayHoc: kh.ngayHoc,
            hocPhi: kh.hocPhi,
            daYeuThich: kh.daYeuThich,
            tongLuotQuanTam: kh.tongLuotQuanTam,
            tongLuotBinhLuan: chiTiet.tongLuotDanhGia,
            soSaoTrungBinh: chiTiet.soSaoTrungBinh,
            hinhAnhUrl: chiTiet.hinhAnh.isNotEmpty ? chiTiet.hinhAnh[0] : null,
          ));
        } catch (e) {
          print('Lỗi lấy chi tiết khóa học ${kh.maKhoaHoc}: $e');
        }
      }

      listQuanTam = fullList;

      // Lưu cache
      await saveQuanTamCache(listQuanTam);
    } catch (e) {
      print('Lỗi load danh sách quan tâm: $e');
    }

    setState(() => loading = false);
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
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : listQuanTam.isEmpty
          ? const Center(child: Text('Bạn chưa quan tâm khóa học nào.'))
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.65,
        ),
        itemCount: listQuanTam.length,
        itemBuilder: (context, index) {
          return KhoaHocCard(khoaHoc: listQuanTam[index]);
        },
      ),
    );
  }
}
