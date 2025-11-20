import 'dart:convert';
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


  Future<void> saveTinTucCache(List<TinTucTuyenDung> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'cache_tin_tuc',
      jsonEncode(data.map((e) => e.toJson()).toList()),
    );
    prefs.setInt('cache_time_tin_tuc', DateTime.now().millisecondsSinceEpoch);
  }
  Future<List<TinTucTuyenDung>?> loadTinTucCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cache_tin_tuc');

    if (jsonString == null) return null;

    final decoded = jsonDecode(jsonString);
    return List<TinTucTuyenDung>.from(
        decoded.map((e) => TinTucTuyenDung.fromJson(e)));
  }
  Future<bool> isTinTucCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('cache_time_tin_tuc') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    const cacheLimit = 30 * 60 * 1000; // 30 phút
    return (now - savedTime) > cacheLimit;
  }
  Future<List<TinTucTuyenDung>> _loadTinTuc() async {
    // Load cache trước
    final cache = await loadTinTucCache();
    final expired = await isTinTucCacheExpired();

    if (cache != null && !expired) {
      return cache;
    }

    try {
      final apiData = await TinTucService.getAllTinTuc();

      // Chỉ lưu khi API có dữ liệu
      if (apiData.isNotEmpty) {
        await saveTinTucCache(apiData);
      }

      return apiData;
    } catch (e) {
      print("Lỗi API: $e");

      // Nếu API lỗi → vẫn trả cache
      if (cache != null) return cache;

      throw Exception("Không thể tải tin tức");
    }
  }

  @override
  void initState() {
    super.initState();
    _futureTinTuc = _loadTinTuc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tin tức tuyển dụng"),
      ),
      body: FutureBuilder<List<TinTucTuyenDung>>(
        future: _futureTinTuc,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Không có tin tức"));
          }

          final danhSachTin = snapshot.data!;
          return ListView.builder(
            itemCount: danhSachTin.length,
            itemBuilder: (context, index) {
              final tin = danhSachTin[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () async {
                    // Chuyển sang trang chi tiết
                    final chiTiet = await TinTucService.getChiTietTin(tin.maTinTuc);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChiTietTinScreen(tin: chiTiet),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (tin.hinhAnh != null)
                        Image.network(
                          tin.hinhAnh!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tin.tieuDeTinTuc,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Ngày đăng: ${tin.ngayDang.day}/${tin.ngayDang.month}/${tin.ngayDang.year}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Ngày ngừng tuyển dụng: ${tin.ngayKetThuc.day}/${tin.ngayKetThuc.month}/${tin.ngayKetThuc.year}",
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            const SizedBox(height: 8),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
      appBar: AppBar(title: Text(tin.tieuDeTinTuc)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tin.hinhAnh != null)
              Image.network(
                tin.hinhAnh!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 12),

            Text(
              "Ngày đăng: ${tin.ngayDang.day}/${tin.ngayDang.month}/${tin.ngayDang.year}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),

            Text(
              "Ngày ngừng tuyển dụng: ${tin.ngayKetThuc.day}/${tin.ngayKetThuc.month}/${tin.ngayKetThuc.year}",
              style: const TextStyle(color: Colors.redAccent),
            ),

            const SizedBox(height: 16),

            // ⭐ Render HTML CKEditor
            Html(
              data: tin.noiDung,
            ),
          ],
        ),
      ),
    );
  }
}
