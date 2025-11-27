import 'dart:convert';
import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
import 'package:do_an_chuyen_nganh/services/auth_service.dart';
import 'package:do_an_chuyen_nganh/widgets/user_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/khoa_hoc_da_dang_ky_response.dart';
import '../../services/khoa_hoc_da_dang_ky_service.dart';

class KhoaHocDaDangKyScreen extends StatefulWidget {
  const KhoaHocDaDangKyScreen({super.key});

  @override
  State<KhoaHocDaDangKyScreen> createState() => _KhoaHocDaDangKyScreenState();
}

class _KhoaHocDaDangKyScreenState extends State<KhoaHocDaDangKyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // USER
  Map<String, String> userData = {};
  String avatarBase64 = '';
  bool isLoggedIn = false;

  // CACHE
  late Future<KhoaHocDaDangKyResponse> _futureData;

  DateTime currentWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _loadUser();
    _futureData = _loadData();
    currentWeekStart = getStartOfWeek(DateTime.now());
  }

  // ---------------------------
  // USER LOAD
  // ---------------------------
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    isLoggedIn = (prefs.getString('token') ?? "").isNotEmpty;

    userData = {
      'username': prefs.getString('username') ?? "",
      'email': prefs.getString('email') ?? "",
      'sdt': prefs.getString('sdt') ?? "",
      'diaChi': prefs.getString('diaChi') ?? "",
      'avatarBase64': prefs.getString('avatarBase64') ?? "",
    };

    avatarBase64 = userData['avatarBase64'] ?? "";
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

  // ---------------------------
  // CACHE
  // ---------------------------
  Future<void> saveCache(KhoaHocDaDangKyResponse data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cache_khdk', jsonEncode(data.toJson()));
    prefs.setInt('cache_khdk_time', DateTime.now().millisecondsSinceEpoch);
  }

  Future<KhoaHocDaDangKyResponse?> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cache_khdk');
    if (jsonString == null) return null;

    return KhoaHocDaDangKyResponse.fromJson(jsonDecode(jsonString));
  }

  Future<bool> isCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('cache_khdk_time') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    return (now - savedTime) > (30 * 60 * 1000); // 30 phút
  }

  Future<KhoaHocDaDangKyResponse> _loadData() async {
    final cache = await loadCache();
    final expired = await isCacheExpired();

    // dùng cache trước
    if (cache != null && !expired) return cache;

    // gọi API
    final apiData = await KhoaHocDaDangKyService.getKhoaHocDaDangKy();
    await saveCache(apiData);

    return apiData;
  }

  // ---------------------------
  // LỊCH HỌC - XỬ LÝ TUẦN
  // ---------------------------
  DateTime getStartOfWeek(DateTime date) {
    int offset = date.weekday == DateTime.sunday ? -6 : 1 - date.weekday;
    return date.add(Duration(days: offset));
  }

  // ---------------------------
  // UI TAB CONTENT
  // ---------------------------
  Widget buildTabContent(KhoaHocDaDangKyResponse data, int tabIndex) {
    switch (tabIndex) {
      case 0: // CHỜ XẾP LỚP
        final list = data.listPhieuDangKy;
        if (list.isEmpty) return const Center(child: Text('Bạn chưa có khóa học chờ xử lý.'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final item = list[i];
            return Card(
              child: ListTile(
                leading: Image.network(item.hinhAnh, width: 80, fit: BoxFit.cover),
                title: Text(item.tenKhoaHoc),
                subtitle: Text('Trạng thái: ${item.trangThaiThanhToan}'),
                trailing: const Text('Chờ xếp lớp', style: TextStyle(color: Colors.orange)),
              ),
            );
          },
        );

      case 1: // ĐANG HỌC (TKB)
        final list = data.listDangHoc;
        if (list.isEmpty) return const Center(child: Text('Bạn không có khóa học đang học.'));

        List<String> caHocList = ['Sáng', 'Chiều'];

        return Column(
          children: [
            // NAVIGATION TUẦN
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() => currentWeekStart = currentWeekStart.subtract(const Duration(days: 7)));
                    },
                  ),
                  Text(
                    'Tuần: '
                        '${currentWeekStart.day}/${currentWeekStart.month} - '
                        '${currentWeekStart.add(const Duration(days: 6)).day}/${currentWeekStart.add(const Duration(days: 6)).month}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() => currentWeekStart = currentWeekStart.add(const Duration(days: 7)));
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: 6, // Thứ 2–7
                itemBuilder: (context, i) {
                  final day = currentWeekStart.add(Duration(days: i));
                  final displayThu = i + 2;

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thứ $displayThu (${day.day}/${day.month})',
                              style: const TextStyle(fontWeight: FontWeight.bold)),

                          const SizedBox(height: 6),

                          for (var ca in caHocList)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ca, style: const TextStyle(fontWeight: FontWeight.w500)),
                                const SizedBox(height: 2),

                                ...list.where((item) {
                                  if (item.ngayKhaiGiang.isAfter(day) || item.ngayKetThuc.isBefore(day)) {
                                    return false;
                                  }

                                  if (!item.ngayHoc.toLowerCase().contains(ca.toLowerCase())) return false;

                                  // parse thứ học T2,4,6
                                  final regex = RegExp(r'T([2-7](?:, *[2-7])*)');
                                  final match = regex.firstMatch(item.ngayHoc);
                                  if (match != null) {
                                    final listThu = match.group(1)!
                                        .split(',')
                                        .map((e) => int.parse(e.trim()))
                                        .toList();
                                    if (!listThu.contains(displayThu)) return false;
                                  }
                                  return true;
                                }).map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Text('${item.tenKhoaHoc} - Phòng: ${item.phongHoc}'),
                                )),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );

      case 2: // CÒN NỢ
        final list = data.listConNo;
        if (list.isEmpty) return const Center(child: Text('Bạn không còn nợ học phí.'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, index) {
            final item = list[index];
            final conNo = item.hocPhi - item.tienDongLan1;
            return Card(
              child: ListTile(
                leading: Image.network(item.hinhAnh, width: 80, fit: BoxFit.cover),
                title: Text(item.tenKhoaHoc),
                subtitle: Text('Còn nợ: $conNo VND'),
              ),
            );
          },
        );

      case 3: // ĐÃ HỌC
        final list = data.listDaHoc;
        if (list.isEmpty) return const Center(child: Text('Bạn chưa hoàn thành khóa học nào.'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, index) {
            final item = list[index];
            return Card(
              child: ListTile(
                leading: Image.network(item.hinhAnh, width: 80, fit: BoxFit.cover),
                title: Text(item.tenKhoaHoc),
                subtitle: Text(
                  'Điểm: ${item.diemTongKet ?? '-'}\n'
                      'Nhận xét: ${item.nhanXetCuaGiaoVien ?? '-'}\n'
                      'Thời gian: ${item.ngayKhaiGiang.day}/${item.ngayKhaiGiang.month} - '
                      '${item.ngayKetThuc.day}/${item.ngayKetThuc.month}',
                ),
              ),
            );
          },
        );

      default:
        return Container();
    }
  }

  // ---------------------------
  // BUILD UI
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        elevation: 4,
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black, // chữ tab đang chọn
          unselectedLabelColor: Colors.white, // chữ tab chưa chọn
          indicator: BoxDecoration(
            color: Colors.white, // nền tab đang chọn
            borderRadius: BorderRadius.circular(8), // bo góc nếu muốn
          ),
          tabs: const [
            Tab(child: SizedBox(width: 100, child: Center(child: Text("Chờ xếp lớp"),),)),
            Tab(child: SizedBox(width: 100, child: Center(child: Text("Đang học"),),)),
            Tab(child: SizedBox(width: 100, child: Center(child: Text("Còn nợ"),),)),
            Tab(child: SizedBox(width: 100, child: Center(child: Text("Đã học"),),)),
          ],
        )
      ),

      body: FutureBuilder<KhoaHocDaDangKyResponse>(
        future: _futureData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return TabBarView(
            controller: _tabController,
            children: List.generate(4, (index) => buildTabContent(data, index)),
          );
        },
      ),
    );
  }
}
