import 'dart:convert';
import 'package:do_an_chuyen_nganh/screens/student/danh_sach_quan_tam_screen.dart';
import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
import 'package:do_an_chuyen_nganh/screens/student/student_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/khoa_hoc.dart';
import '../../services/khoa_hoc_student_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/khoa_hoc_card.dart';
import '../../widgets/user_header_widget.dart';
import '../../widgets/search_and_filter_widget.dart';
import '../auth/login_screen.dart';
import '../auth/profile_screen.dart';

class KhoaHocListScreen extends StatefulWidget {
  const KhoaHocListScreen({super.key});

  @override
  State<KhoaHocListScreen> createState() => _KhoaHocListScreenState();
}

class _KhoaHocListScreenState extends State<KhoaHocListScreen> {
  List<KhoaHoc> listKhoaHoc = [];
  bool loading = true;
  bool isLoggedIn = false;
  // Filter / search
  String searchText = '';
  int priceFilter = 0;
  String typeFilter = '';

  // User info
  Map<String, String> userData = {};
  String avatarBase64 = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  Future<void> saveKhoaHocCache(List<KhoaHoc> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cache_khoa_hoc', jsonEncode(data.map((e) => e.toJson()).toList()));
    prefs.setInt('cache_time_khoa_hoc', DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<KhoaHoc>?> loadKhoaHocCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cache_khoa_hoc');

    if (jsonString == null) return null;

    final decoded = jsonDecode(jsonString);
    return List<KhoaHoc>.from(decoded.map((e) => KhoaHoc.fromJson(e)));
  }
  Future<bool> isKhoaHocCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('cache_time_khoa_hoc') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    const cacheLimit = 30 * 60 * 1000; // 30 phút
    return (now - savedTime) > cacheLimit;
  }

  Future<void> _loadData() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();

    // Load user
    userData = {
      'username': prefs.getString('username') ?? 'Người dùng',
      'email': prefs.getString('email') ?? '',
      'sdt': prefs.getString('sdt') ?? '',
      'diaChi': prefs.getString('diaChi') ?? '',
      'avatarBase64': prefs.getString('avatarBase64') ?? '',
    };
    avatarBase64 = userData['avatarBase64'] ?? '';
    // Cập nhật trạng thái đăng nhập
    setState(() {
      isLoggedIn = prefs.getString('username') != null;
    });
    // ---------- LOAD CACHE TRƯỚC ----------
    final cache = await loadKhoaHocCache();
    final expired = await isKhoaHocCacheExpired();

    if (cache != null && !expired) {
      // Có cache và chưa hết hạn → load cache
      listKhoaHoc = cache;
      setState(() => loading = false);
    }

    // ---------- GỌI API SAU ----------
    try {
      final apiData = await KhoaHocService.getAllKhoaHoc();
      listKhoaHoc = apiData;

      // lưu cache lại
      await saveKhoaHocCache(apiData);
    } catch (e) {
      print("Lỗi API: $e");
    }

    setState(() => loading = false);
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

  Future<void> _searchOrFilter() async {
    setState(() => loading = true);
    listKhoaHoc = await KhoaHocService.searchOrFilter(
      ten: searchText,
      tenLoai: typeFilter,
    );
    setState(() => loading = false);
  }

  Future<void> _filterByPrice(int luaChon) async {
    setState(() => loading = true);
    listKhoaHoc = await KhoaHocService.filterByPrice(luaChon);
    setState(() {
      priceFilter = luaChon;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        title: UserAppBarWidget(
          isLoggedIn: isLoggedIn,           // 🔥 Truyền trạng thái đăng nhập
          username: userData['username'] ?? '',
          email: userData['email'] ?? '',
          sdt: userData['sdt'] ?? '',
          diaChi: userData['diaChi'] ?? '',
          avatarBase64: avatarBase64,
          onLogout: _logout,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SearchAndFilterWidget(
            searchText: searchText,
            onSearchChanged: (val) => searchText = val,
            onSearchPressed: _searchOrFilter,
            typeFilter: typeFilter,
            onTypeSelected: (val) {
              if (val == 'goQuanTam') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DanhSachQuanTamScreen(),
                  ),
                );
                return;
              }
              // xử lý filter loại
              setState(() => typeFilter = val);
              _searchOrFilter();
            },
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _priceButton(0, 'Tất cả'),
                _priceButton(1, 'Cao -> Thấp'),
                _priceButton(2, 'Thấp -> Cao'),
                _priceButton(3, '< 5M'),
                _priceButton(4, '5M -> 7M'),
                _priceButton(5, '> 7M'),
              ],
            ),
          ),
          Expanded(
            child: listKhoaHoc.isEmpty
                ? const Center(child: Text('Không tìm thấy khóa học'))
                : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: listKhoaHoc.length,
              itemBuilder: (context, index) {
                return KhoaHocCard(khoaHoc: listKhoaHoc[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceButton(int luaChon, String text) {
    final selected = priceFilter == luaChon;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? Colors.blue : Colors.grey[200],
          foregroundColor: selected ? Colors.white : Colors.black,
        ),
        onPressed: () => _filterByPrice(luaChon),
        child: Text(text),
      ),
    );
  }
}
