import 'dart:convert';
import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
import 'package:do_an_chuyen_nganh/services/auth_service.dart';
import 'package:do_an_chuyen_nganh/widgets/user_header_widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/tin_tuc_tuyen_dung.dart';
import '../../services/tin_tuc_service.dart';

class TinTucScreen extends StatefulWidget {
  const TinTucScreen({super.key});

  @override
  State<TinTucScreen> createState() => _TinTucScreenState();
}

class _TinTucScreenState extends State<TinTucScreen> {
  late Future<List<TinTucTuyenDung>> _futureTinTuc;
  Map<String, String> userData = {};
  String avatarBase64 = '';
  bool isLoggedIn = false;

  Future<void> saveTinTucCache(List<TinTucTuyenDung> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cache_tin_tuc', jsonEncode(data.map((e) => e.toJson()).toList()));
    prefs.setInt('cache_time_tin_tuc', DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<TinTucTuyenDung>?> loadTinTucCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cache_tin_tuc');
    if (jsonString == null) return null;
    final decoded = jsonDecode(jsonString);
    return List<TinTucTuyenDung>.from(decoded.map((e) => TinTucTuyenDung.fromJson(e)));
  }

  Future<bool> isTinTucCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('cache_time_tin_tuc') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const cacheLimit = 30 * 60 * 1000;
    return (now - savedTime) > cacheLimit;
  }

  Future<List<TinTucTuyenDung>> _loadTinTuc() async {
    final cache = await loadTinTucCache();
    final expired = await isTinTucCacheExpired();
    if (cache != null && !expired) return cache;
    try {
      final apiData = await TinTucService.getAllTinTuc();
      if (apiData.isNotEmpty) await saveTinTucCache(apiData);
      return apiData;
    } catch (e) {
      if (cache != null) return cache;
      throw Exception("Không thể tải tin tức");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _futureTinTuc = _loadTinTuc();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF7B1FA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
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
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tin tức tuyển dụng',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cơ hội việc làm hấp dẫn dành cho bạn',
                  style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          // News List
          Expanded(
            child: FutureBuilder<List<TinTucTuyenDung>>(
              future: _futureTinTuc,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF5E35B1)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Không có tin tức"));
                }
                final danhSachTin = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: danhSachTin.length,
                  itemBuilder: (context, index) => _buildNewsCard(danhSachTin[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNewsCard(TinTucTuyenDung tin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final chiTiet = await TinTucService.getChiTietTin(tin.maTinTuc);
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChiTietTinScreen(tin: chiTiet)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (tin.hinhAnh != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  tin.hinhAnh!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tin.tieuDeTinTuc,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildDateChip(Icons.calendar_today, '${tin.ngayDang.day}/${tin.ngayDang.month}/${tin.ngayDang.year}', const Color(0xFF1E88E5)),
                      const SizedBox(width: 12),
                      _buildDateChip(Icons.event_busy, '${tin.ngayKetThuc.day}/${tin.ngayKetThuc.month}/${tin.ngayKetThuc.year}', Colors.redAccent),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class ChiTietTinScreen extends StatelessWidget {
  final TinTucTuyenDung tin;
  const ChiTietTinScreen({super.key, required this.tin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: tin.hinhAnh != null
                  ? Image.network(tin.hinhAnh!, fit: BoxFit.cover)
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF7B1FA2)]),
                      ),
                    ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tin.tieuDeTinTuc,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(Icons.calendar_today, 'Đăng: ${tin.ngayDang.day}/${tin.ngayDang.month}/${tin.ngayDang.year}', const Color(0xFF1E88E5)),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.event_busy, 'Hết hạn: ${tin.ngayKetThuc.day}/${tin.ngayKetThuc.month}/${tin.ngayKetThuc.year}', Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  Html(data: tin.noiDung),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
