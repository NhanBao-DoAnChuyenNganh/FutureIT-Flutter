import 'dart:convert';
import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
import 'package:do_an_chuyen_nganh/services/auth_service.dart';
import 'package:do_an_chuyen_nganh/widgets/user_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/khoa_hoc_da_dang_ky_response.dart';
import '../../models/trang_thai_diem_danh_model.dart';
import '../../services/khoa_hoc_da_dang_ky_service.dart';
import '../../services/student_diem_danh_service.dart';

class KhoaHocDaDangKyScreen extends StatefulWidget {
  const KhoaHocDaDangKyScreen({super.key});

  @override
  State<KhoaHocDaDangKyScreen> createState() => _KhoaHocDaDangKyScreenState();
}

class _KhoaHocDaDangKyScreenState extends State<KhoaHocDaDangKyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, String> userData = {};
  String avatarBase64 = '';
  bool isLoggedIn = false;
  late Future<KhoaHocDaDangKyResponse> _futureData;
  DateTime currentWeekStart = DateTime.now();
  Map<String, TrangThaiDiemDanh> trangThaiDiemDanh = {};
  bool isLoadingDiemDanh = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUser();
    _futureData = _loadData();
    currentWeekStart = getStartOfWeek(DateTime.now());
  }

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
    return (DateTime.now().millisecondsSinceEpoch - savedTime) > (30 * 60 * 1000);
  }

  Future<KhoaHocDaDangKyResponse> _loadData() async {
    final cache = await loadCache();
    final expired = await isCacheExpired();
    if (cache != null && !expired) return cache;
    final apiData = await KhoaHocDaDangKyService.getKhoaHocDaDangKy();
    await saveCache(apiData);
    return apiData;
  }

  DateTime getStartOfWeek(DateTime date) {
    int offset = date.weekday == DateTime.sunday ? -6 : 1 - date.weekday;
    return date.add(Duration(days: offset));
  }

  Future<void> _loadTrangThaiDiemDanh(List<dynamic> danhSachLop) async {
    if (danhSachLop.isEmpty) return;
    
    setState(() => isLoadingDiemDanh = true);
    
    // Chuyển đổi sang List<Map> để truyền cả thông tin ngayHoc
    final danhSachLopMap = danhSachLop.map((item) => {
      'maLopHoc': item.maLopHoc,
      'ngayHoc': item.ngayHoc,
      'ngayKhaiGiang': item.ngayKhaiGiang,
      'ngayKetThuc': item.ngayKetThuc,
    }).toList();
    
    print('Loading điểm danh cho ${danhSachLopMap.length} lớp');
    print('Tuần bắt đầu: $currentWeekStart');
    
    final result = await StudentDiemDanhService.getTrangThaiDiemDanhTuan(
      danhSachLopMap,
      currentWeekStart,
    );
    
    print('Kết quả điểm danh: ${result.length} records');
    result.forEach((key, value) {
      print('   - Key: $key, DaDiemDanh: ${value.daDiemDanh}, CoMat: ${value.coMat}');
    });
    
    setState(() {
      trangThaiDiemDanh = result;
      isLoadingDiemDanh = false;
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
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF7B1FA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Học tập của tôi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Quản lý khóa học đã đăng ký', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
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
              preferredSize: const Size.fromHeight(50),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF7B1FA2), Color(0xFF5E35B1)]),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Chờ lớp'),
                    Tab(text: 'Đang học'),
                    Tab(text: 'Còn nợ'),
                    Tab(text: 'Đã học'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: FutureBuilder<KhoaHocDaDangKyResponse>(
          future: _futureData,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF5E35B1)));
            }
            return TabBarView(
              controller: _tabController,
              children: List.generate(4, (index) => _buildTabContent(snapshot.data!, index)),
            );
          },
        ),
      ),
    );
  }


  Widget _buildTabContent(KhoaHocDaDangKyResponse data, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _buildChoXepLop(data.listPhieuDangKy);
      case 1:
        return _buildDangHoc(data.listDangHoc);
      case 2:
        return _buildConNo(data.listConNo);
      case 3:
        return _buildDaHoc(data.listDaHoc);
      default:
        return Container();
    }
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildChoXepLop(List<dynamic> list) {
    if (list.isEmpty) return _buildEmptyState('Không có khóa học chờ xếp lớp', Icons.hourglass_empty);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final item = list[i];
        return _buildCourseCard(
          image: item.hinhAnh,
          title: item.tenKhoaHoc,
          subtitle: 'Trạng thái: ${item.trangThaiThanhToan}',
          badge: 'Chờ xếp lớp',
          badgeColor: Colors.orange,
        );
      },
    );
  }

  Widget _buildDangHoc(List<dynamic> list) {
    if (list.isEmpty) return _buildEmptyState('Không có khóa học đang học', Icons.school_outlined);
    
    // Load trạng thái điểm danh khi vào tab (sau khi build xong)
    if (trangThaiDiemDanh.isEmpty && !isLoadingDiemDanh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTrangThaiDiemDanh(list);
      });
    }
    
    List<String> caHocList = ['Sáng', 'Chiều'];
    return Column(
      children: [
        // Week Navigation
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Color(0xFF5E35B1)),
                onPressed: () {
                  setState(() => currentWeekStart = currentWeekStart.subtract(const Duration(days: 7)));
                  _loadTrangThaiDiemDanh(list);
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF7B1FA2)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentWeekStart.day}/${currentWeekStart.month} - ${currentWeekStart.add(const Duration(days: 6)).day}/${currentWeekStart.add(const Duration(days: 6)).month}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Color(0xFF5E35B1)),
                onPressed: () {
                  setState(() => currentWeekStart = currentWeekStart.add(const Duration(days: 7)));
                  _loadTrangThaiDiemDanh(list);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            itemBuilder: (context, i) {
              final day = currentWeekStart.add(Duration(days: i));
              final displayThu = i + 2;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [const Color(0xFF1E88E5).withOpacity(0.1), const Color(0xFF7B1FA2).withOpacity(0.1)]),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Text('Thứ $displayThu - ${day.day}/${day.month}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5E35B1))),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: caHocList.map((ca) {
                          final filtered = list.where((item) {
                            if (item.ngayKhaiGiang.isAfter(day) || item.ngayKetThuc.isBefore(day)) return false;
                            if (!item.ngayHoc.toLowerCase().contains(ca.toLowerCase())) return false;
                            final regex = RegExp(r'T([2-7](?:, *[2-7])*)');
                            final match = regex.firstMatch(item.ngayHoc);
                            if (match != null) {
                              final listThu = match.group(1)!.split(',').map((e) => int.parse(e.trim())).toList();
                              if (!listThu.contains(displayThu)) return false;
                            }
                            return true;
                          }).toList();
                          if (filtered.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ca == 'Sáng' ? Colors.amber.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(ca, style: TextStyle(fontWeight: FontWeight.w600, color: ca == 'Sáng' ? Colors.orange.shade700 : Colors.blue.shade700, fontSize: 12)),
                              ),
                              const SizedBox(height: 8),
                              ...filtered.map((item) {
                                final key = '${item.maLopHoc}_${day.day}_${day.month}';
                                final trangThai = trangThaiDiemDanh[key];
                                final daDiemDanh = trangThai?.daDiemDanh ?? false;
                                final coMat = trangThai?.coMat ?? false;
                                
                                // Debug
                                if (trangThai != null) {
                                  print('Tìm thấy điểm danh: $key -> CoMat: $coMat');
                                }
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        daDiemDanh 
                                          ? (coMat ? Icons.check_circle : Icons.cancel)
                                          : Icons.circle,
                                        size: daDiemDanh ? 16 : 8,
                                        color: daDiemDanh
                                          ? (coMat ? Colors.green : Colors.red)
                                          : const Color(0xFF5E35B1),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${item.tenKhoaHoc} - Phòng: ${item.phongHoc}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      if (daDiemDanh)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: coMat 
                                              ? Colors.green.withOpacity(0.15)
                                              : Colors.red.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            coMat ? 'Có mặt' : 'Vắng',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: coMat ? Colors.green.shade700 : Colors.red.shade700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 8),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildConNo(List<dynamic> list) {
    if (list.isEmpty) return _buildEmptyState('Không còn nợ học phí', Icons.check_circle_outline);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, index) {
        final item = list[index];
        final conNo = item.hocPhi - item.tienDongLan1;
        return _buildCourseCard(
          image: item.hinhAnh,
          title: item.tenKhoaHoc,
          subtitle: 'Còn nợ: ${_formatPrice(conNo.toDouble())}',
          badge: 'Còn nợ',
          badgeColor: Colors.red,
        );
      },
    );
  }

  Widget _buildDaHoc(List<dynamic> list) {
    if (list.isEmpty) return _buildEmptyState('Chưa hoàn thành khóa học nào', Icons.emoji_events_outlined);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, index) {
        final item = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(item.hinhAnh, height: 120, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 120, color: Colors.grey.shade200, child: const Icon(Icons.image, size: 40)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(item.tenKhoaHoc, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Hoàn thành', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(Icons.star, 'Điểm: ${item.diemTongKet ?? '-'}', Colors.amber),
                        const SizedBox(width: 8),
                        _buildInfoChip(Icons.calendar_today, '${item.ngayKhaiGiang.day}/${item.ngayKhaiGiang.month} - ${item.ngayKetThuc.day}/${item.ngayKetThuc.month}', const Color(0xFF5E35B1)),
                      ],
                    ),
                    if (item.nhanXetCuaGiaoVien != null && item.nhanXetCuaGiaoVien.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.comment, size: 18, color: Color(0xFF5E35B1)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item.nhanXetCuaGiaoVien, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontStyle: FontStyle.italic))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCourseCard({required String image, required String title, required String subtitle, required String badge, required Color badgeColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            child: Image.network(image, width: 100, height: 100, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 100, height: 100, color: Colors.grey.shade200, child: const Icon(Icons.image)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A2E)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: badgeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final priceInt = price.toInt();
    return '${priceInt.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} VND';
  }
}

