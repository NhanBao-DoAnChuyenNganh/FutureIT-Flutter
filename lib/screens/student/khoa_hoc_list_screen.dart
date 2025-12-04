import 'dart:convert';
import 'package:do_an_chuyen_nganh/screens/student/danh_sach_quan_tam_screen.dart';
import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
import 'package:do_an_chuyen_nganh/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/khoa_hoc.dart';
import '../../services/khoa_hoc_student_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/khoa_hoc_card.dart';
import '../../widgets/user_header_widget.dart';
import '../../widgets/search_and_filter_widget.dart';

class KhoaHocListScreen extends StatefulWidget {
  const KhoaHocListScreen({super.key});

  @override
  State<KhoaHocListScreen> createState() => _KhoaHocListScreenState();
}

class _KhoaHocListScreenState extends State<KhoaHocListScreen> {
  List<KhoaHoc> listKhoaHoc = [];
  bool loading = true;
  bool isLoggedIn = false;
  String searchText = '';
  int priceFilter = 0;
  String typeFilter = '';
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
    const cacheLimit = 30 * 60 * 1000;
    return (now - savedTime) > cacheLimit;
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    final prefs = await SharedPreferences.getInstance();
    userData = {
      'username': prefs.getString('username') ?? 'Người dùng',
      'email': prefs.getString('email') ?? '',
      'sdt': prefs.getString('sdt') ?? '',
      'diaChi': prefs.getString('diaChi') ?? '',
      'avatarBase64': prefs.getString('avatarBase64') ?? '',
    };
    avatarBase64 = userData['avatarBase64'] ?? '';
    setState(() => isLoggedIn = prefs.getString('username') != null);

    final cache = await loadKhoaHocCache();
    final expired = await isKhoaHocCacheExpired();
    if (cache != null && !expired) {
      listKhoaHoc = cache;
      setState(() => loading = false);
    }

    try {
      final apiData = await KhoaHocService.getAllKhoaHoc();
      listKhoaHoc = apiData;
      await saveKhoaHocCache(apiData);
    } catch (e) {
      debugPrint("Lỗi API: $e");
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
    listKhoaHoc = await KhoaHocService.searchOrFilter(ten: searchText, tenLoai: typeFilter);
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
      backgroundColor: const Color(0xFFF5F7FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 180,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Khám phá khóa học',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tìm kiếm khóa học phù hợp với bạn',
                          style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            title: UserAppBarWidget(
              isLoggedIn: isLoggedIn,
              username: userData['username'] ?? '',
              email: userData['email'] ?? '',
              sdt: userData['sdt'] ?? '',
              diaChi: userData['diaChi'] ?? '',
              avatarBase64: avatarBase64,
              onLogout: _logout,
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.only(bottom: 16),
                child: SearchAndFilterWidget(
                  searchText: searchText,
                  onSearchChanged: (val) => searchText = val,
                  onSearchPressed: _searchOrFilter,
                  typeFilter: typeFilter,
                  onTypeSelected: (val) {
                    if (val == 'goQuanTam') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const DanhSachQuanTamScreen()));
                      return;
                    }
                    setState(() => typeFilter = val);
                    _searchOrFilter();
                  },
                ),
              ),
            ),
          ),
        ],
        body: loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  // Price Filter Chips
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildFilterChip(0, 'Tất cả', Icons.apps),
                          _buildFilterChip(1, 'Cao → Thấp', Icons.arrow_downward),
                          _buildFilterChip(2, 'Thấp → Cao', Icons.arrow_upward),
                          _buildFilterChip(3, '< 5M', Icons.money_off),
                          _buildFilterChip(4, '5M - 7M', Icons.attach_money),
                          _buildFilterChip(5, '> 7M', Icons.monetization_on),
                        ],
                      ),
                    ),
                  ),
                  // Course Grid
                  Expanded(
                    child: listKhoaHoc.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text('Không tìm thấy khóa học', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.58,
                            ),
                            itemCount: listKhoaHoc.length,
                            itemBuilder: (context, index) => KhoaHocCard(khoaHoc: listKhoaHoc[index]),
                          ),
                  ),
                ],
              ),
      ),
    );
  }


  Widget _buildFilterChip(int luaChon, String text, IconData icon) {
    final selected = priceFilter == luaChon;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => _filterByPrice(luaChon),
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: selected ? AppColors.primary.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : AppColors.primary),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
