import 'dart:convert';
import 'package:flutter/material.dart';
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
  TextEditingController noiDungController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChiTiet();
  }

  Future<void> saveChiTietCache(ChiTietKhoaHoc data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cache_chi_tiet_${data.maKhoaHoc}', jsonEncode(data.toJson()));
    prefs.setInt('cache_time_chi_tiet_${data.maKhoaHoc}', DateTime.now().millisecondsSinceEpoch);
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

  Future<void> _loadChiTiet() async {
    setState(() => loading = true);

    // Kiểm tra cache trước
    final cache = await loadChiTietCache(widget.maKhoaHoc);
    final expired = await isChiTietCacheExpired(widget.maKhoaHoc);
    if (cache != null && !expired) {
      setState(() {
        chiTiet = cache;
        loading = false;
      });
    }

    // Gọi API và cập nhật cache
    try {
      final data = await KhoaHocService.getChiTietKhoaHoc(widget.maKhoaHoc);
      setState(() => chiTiet = data);
      await saveChiTietCache(data);
    } catch (e) {
      print("Lỗi tải chi tiết khóa học: $e");
    }

    setState(() => loading = false);
  }

  Future<void> _sendDanhGia() async {
    if (chiTiet == null) return;
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
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi đánh giá thành công')),
      );
      noiDungController.clear();
      selectedStar = 0;
      _loadChiTiet(); // reload chi tiết để cập nhật đánh giá
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gửi đánh giá thất bại')),
      );
    }
  }

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
            // Ảnh chính và thumbnail
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
                  Text("Học phí: ${chiTiet!.hocPhi.toStringAsFixed(0)} VND", style: const TextStyle(color: Colors.red)),
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
                  Text(chiTiet!.moTa),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text("Đánh giá khóa học", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...chiTiet!.danhGia.map((dg) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: dg.avatarBase64.isNotEmpty
                            ? MemoryImage(base64Decode(dg.avatarBase64))
                            : null,
                      ),
                      title: Text(dg.user),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStarRating(dg.soSaoDanhGia.toDouble()),
                          Text(dg.noiDungDanhGia),
                          Text(dg.ngayDanhGia, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  )),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text("Gửi đánh giá của bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          icon: Icon(i < selected ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
          onPressed: () {
            setState(() => selected = i + 1);
            widget.onSelected(selected);
          },
        );
      }),
    );
  }
}
