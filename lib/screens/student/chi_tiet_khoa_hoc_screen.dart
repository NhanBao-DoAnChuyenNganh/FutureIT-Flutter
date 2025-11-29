import 'dart:convert';
import 'package:do_an_chuyen_nganh/screens/auth/login_screen.dart';
import 'package:do_an_chuyen_nganh/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/chi_tiet_khoa_hoc.dart';
import '../../services/khoa_hoc_student_service.dart';

class ChiTietKhoaHocScreen extends StatefulWidget {
  final int maKhoaHoc;

  const ChiTietKhoaHocScreen({super.key, required this.maKhoaHoc});

  @override
  State<ChiTietKhoaHocScreen> createState() => _ChiTietKhoaHocScreenState();
}

class _ChiTietKhoaHocScreenState extends State<ChiTietKhoaHocScreen> {
  ChiTietKhoaHoc? chiTiet;
  bool loading = true;
  int selectedImageIndex = 0;
  int selectedStar = 0;
  bool daQuanTam = false;
  TextEditingController noiDungController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChiTiet();
    _loadTrangThaiQuanTam();
  }

  // ---------------- CACHE -----------------
  Future<void> saveChiTietCache(ChiTietKhoaHoc data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cache_chi_tiet_${data.maKhoaHoc}', jsonEncode(data.toJson()));
    await prefs.setInt('cache_time_chi_tiet_${data.maKhoaHoc}', DateTime.now().millisecondsSinceEpoch);
  }

  Future<ChiTietKhoaHoc?> loadChiTietCache(int maKhoaHoc) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cache_chi_tiet_$maKhoaHoc');
    if (jsonString == null) return null;
    final decoded = jsonDecode(jsonString);
    return ChiTietKhoaHoc.fromJson(decoded);
  }

  Future<bool> isChiTietCacheExpired(int maKhoaHoc) async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('cache_time_chi_tiet_$maKhoaHoc') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const cacheLimit = 30 * 60 * 1000; // 30 phút
    return (now - savedTime) > cacheLimit;
  }

  // ---------------- LOAD CHI TIẾT -----------------
  Future<void> _loadChiTiet() async {
    setState(() => loading = true);

    // Load cache trước
    final cache = await loadChiTietCache(widget.maKhoaHoc);
    final expired = await isChiTietCacheExpired(widget.maKhoaHoc);
    if (cache != null && !expired && mounted) {
      setState(() {
        chiTiet = cache;
        loading = false;
      });
    }

    try {
      final data = await KhoaHocService.getChiTietKhoaHoc(widget.maKhoaHoc);
      if (!mounted) return;
      setState(() => chiTiet = data);

      // Lưu cache
      await saveChiTietCache(data);
    } catch (e) {
      print("Lỗi tải chi tiết khóa học: $e");
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  // ---------------- LOAD TRẠNG THÁI QUAN TÂM -----------------
  Future<void> _loadTrangThaiQuanTam() async {
    final prefs = await SharedPreferences.getInstance();
    // Lấy cache trước
    final cached = prefs.getBool('cache_daQuanTam_${widget.maKhoaHoc}');
    if (cached != null && mounted) {
      setState(() {
        daQuanTam = cached;
      });
    }

    try {
      final dsQuanTam = await KhoaHocService.getDanhSachQuanTam();
      final isQuanTam = dsQuanTam.any((k) => k.maKhoaHoc == widget.maKhoaHoc);
      if (!mounted) return;
      setState(() {
        daQuanTam = isQuanTam;
      });

      // Lưu cache
      await prefs.setBool('cache_daQuanTam_${widget.maKhoaHoc}', isQuanTam);
    } catch (e) {
      print("Lỗi tải trạng thái quan tâm: $e");
    }
  }
  Future<bool> _checkLogin() async {
    bool loggedIn = await AuthService.isLoggedIn();
    if (loggedIn) return true;

    // Nếu chưa đăng nhập → hiện dialog
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: const Text('Bạn chưa đăng nhập. Vui lòng đăng nhập để tiếp tục.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // chỉ đóng dialog
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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

    return false;
  }

  // ---------------- TOGGLE QUAN TÂM -----------------
  Future<void> _toggleQuanTam() async {
    // 1 Kiểm tra đăng nhập trước
    bool loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) {
      // Hiện dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thông báo'),
          content: const Text('Bạn chưa đăng nhập. Vui lòng đăng nhập để tiếp tục.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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
      return; // 🚫 Ngừng không cho quan tâm
    }

    //  Gọi API toggle yêu thích
    final success = await KhoaHocService.toggleYeuThich(widget.maKhoaHoc);

    if (!mounted) return;

    // Xử lý lỗi API
    if (!success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lỗi'),
          content: const Text('Không thể cập nhật trạng thái quan tâm.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // 4 Thành công → cập nhật UI + cache
    setState(() => daQuanTam = !daQuanTam);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cache_daQuanTam_${widget.maKhoaHoc}', daQuanTam);

    //  Hiện thông báo (SnackBar hoặc bạn muốn dialog cũng được)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(daQuanTam ? 'Đã quan tâm khóa học' : 'Bỏ quan tâm'),
      ),
    );
  }


  // ---------------- GỬI ĐÁNH GIÁ -----------------
  Future<void> _sendDanhGia() async {
    if (chiTiet == null) return;
    if (!await _checkLogin()) return;
    if (selectedStar == 0 || noiDungController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao và nhập nội dung')),
      );
      return;
    }
    final success = await KhoaHocService.guiDanhGia(
      maKhoaHoc: chiTiet!.maKhoaHoc,
      soSao: selectedStar,
      noiDung: noiDungController.text,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi đánh giá thành công')),
      );
      noiDungController.clear();
      selectedStar = 0;
      _loadChiTiet(); // reload chi tiết để cập nhật đánh giá và lượt đánh giá
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi đánh giá thất bại')),
      );
    }
  }

  // ---------------- BUILD -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(chiTiet?.tenKhoaHoc ?? "Chi tiết khóa học")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : chiTiet == null
          ? const Center(child: Text("Không tìm thấy khóa học"))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chiTiet!.hinhAnh.isNotEmpty)
              Column(
                children: [
                  Image.network(
                    chiTiet!.hinhAnh[selectedImageIndex],
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: chiTiet!.hinhAnh.length,
                      itemBuilder: (_, index) => GestureDetector(
                        onTap: () => setState(() => selectedImageIndex = index),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedImageIndex == index ? Colors.blue : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Image.network(
                            chiTiet!.hinhAnh[index],
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chiTiet!.tenKhoaHoc,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text("Ngày học: ${chiTiet!.ngayHoc}"),
                  Text("Giờ: ${chiTiet!.gioBatDau} - ${chiTiet!.gioKetThuc}"),
                  Text("Học phí: ${chiTiet!.hocPhi.toStringAsFixed(0)} VND",
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStarRating(chiTiet!.soSaoTrungBinh),
                      const SizedBox(width: 8),
                      Text("(${chiTiet!.tongLuotDanhGia} lượt đánh giá)"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("Mô tả:", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Html(data: chiTiet!.moTa),
                  const SizedBox(height: 16),

                  // Nút quan tâm
                  ElevatedButton.icon(
                    onPressed: _toggleQuanTam,
                    icon: Icon(daQuanTam ? Icons.favorite : Icons.favorite_border),
                    label: Text(daQuanTam ? 'Đã quan tâm' : 'Quan tâm khóa học này'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: daQuanTam ? Colors.red : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Gửi đánh giá lên trên
                  const Text("Gửi đánh giá của bạn",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  _StarInput(onSelected: (val) => selectedStar = val),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noiDungController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Nêu ý kiến của bạn",
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _sendDanhGia,
                    icon: const Icon(Icons.send),
                    label: const Text("Gửi đánh giá"),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Hiển thị đánh giá
                  chiTiet!.danhGia.isEmpty
                      ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Khóa học hiện chưa có đánh giá",
                      style: TextStyle(
                          color: Colors.blueGrey, fontStyle: FontStyle.italic),
                    ),
                  )
                      : Column(
                    children: chiTiet!.danhGia
                        .map(
                          (dg) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: dg.avatarBase64.isNotEmpty
                              ? CircleAvatar(
                              backgroundImage:
                              MemoryImage(base64Decode(dg.avatarBase64)))
                              : null,
                          title: Text(dg.user),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStarRating(dg.soSaoDanhGia.toDouble()),
                              Text(dg.noiDungDanhGia),
                              Text(dg.ngayDanhGia,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (rating >= i + 1) return const Icon(Icons.star, color: Colors.amber);
        if (rating >= i + 0.5) return const Icon(Icons.star_half, color: Colors.amber);
        return const Icon(Icons.star_border, color: Colors.amber);
      }),
    );
  }
}

class _StarInput extends StatefulWidget {
  final Function(int) onSelected;
  const _StarInput({super.key, required this.onSelected});

  @override
  State<_StarInput> createState() => _StarInputState();
}

class _StarInputState extends State<_StarInput> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        return IconButton(
          icon: Icon(i < selected ? Icons.star : Icons.star_border,
              color: Colors.amber, size: 32),
          onPressed: () {
            setState(() => selected = i + 1);
            widget.onSelected(selected);
          },
        );
      }),
    );
  }
}
