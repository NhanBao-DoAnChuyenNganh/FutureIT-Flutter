import 'package:flutter/material.dart';
import '../../models/chi_tiet_lop_model.dart';
import '../../services/teacher_home_service.dart';

class TeacherClassDetailScreen extends StatefulWidget {
  final int maLop;
  const TeacherClassDetailScreen({super.key, required this.maLop});

  @override
  State<TeacherClassDetailScreen> createState() =>
      _TeacherClassDetailScreenState();
}

class _TeacherClassDetailScreenState extends State<TeacherClassDetailScreen> {
  late Future<ChiTietLop?> _futureData;
  Map<String, TextEditingController> diemControllers = {};
  Map<String, TextEditingController> nhanXetControllers = {};
  bool isLoading = false;
  bool _controllersInit = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futureData = TeacherHomeService.getChiTietLop(widget.maLop);
  }

  @override
  void dispose() {
    diemControllers.forEach((_, ctrl) => ctrl.dispose());
    nhanXetControllers.forEach((_, ctrl) => ctrl.dispose());
    searchController.dispose();
    super.dispose();
  }

  void _initControllers(List<HocVienInfo> students) {
    for (var s in students) {
      if (!diemControllers.containsKey(s.id)) {
        diemControllers[s.id] = TextEditingController(
          text: s.diemTongKet?.toString() ?? '',
        );
        nhanXetControllers[s.id] = TextEditingController(
          text: s.nhanXetCuaGiaoVien ?? '',
        );
      }
    }
  }

  Future<void> _luuNhanXet(String id, int maLop) async {
    final d = diemControllers[id]?.text ?? '';
    final n = nhanXetControllers[id]?.text ?? '';

    if (d.isEmpty || n.isEmpty) {
      _showMsg('Vui lòng nhập đầy đủ điểm và nhận xét', Colors.red);
      return;
    }

    final diem = int.tryParse(d);
    if (diem == null || diem < 0 || diem > 100) {
      _showMsg('Điểm phải từ 0 đến 100', Colors.red);
      return;
    }

    setState(() => isLoading = true);
    final ok = await TeacherHomeService.luuNhanXet(
      idHocVien: id,
      maLop: maLop,
      diem: diem,
      nhanXet: n,
    );
    setState(() => isLoading = false);

    if (ok) {
      _showMsg('Lưu thành công', Colors.green);
    } else {
      _showMsg('Lưu thất bại', Colors.red);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Chi tiết lớp học',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<ChiTietLop?>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Không thể tải dữ liệu'));
          }

          final data = snapshot.data!;

          if (!_controllersInit) {
            _initControllers(data.danhSachHocVien);
            _controllersInit = true;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Quay lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lớp #${data.lop.maLopHoc} - ${data.lop.tenKhoaHoc}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(data.lop),
                  const SizedBox(height: 24),
                  const Text(
                    'Danh sách học viên',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tổng: ${data.danhSachHocVien.length} học viên',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm tên học sinh...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTable(data.danhSachHocVien, data.lop.maLopHoc),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(LopInfo lop) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lop.hinhAnh != null && lop.hinhAnh!.isNotEmpty)
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    lop.hinhAnh!,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) {
                      return Container(
                        height: 180,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin lớp học',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _infoRow(Icons.book, 'Khóa học:', lop.tenKhoaHoc),
                  const SizedBox(height: 8),
                  _infoRow(Icons.location_on, 'Phòng học:', lop.tenPhongHoc),
                  const SizedBox(height: 8),
                  _infoRow(
                    Icons.calendar_today,
                    'Thời gian:',
                    '${lop.ngayKhaiGiang.day}/${lop.ngayKhaiGiang.month}/${lop.ngayKhaiGiang.year} - ${lop.ngayKetThuc.day}/${lop.ngayKetThuc.month}/${lop.ngayKetThuc.year}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Build table với nút lưu ở cột riêng
  Widget _buildTable(List<HocVienInfo> students, int maLop) {
    // Lọc danh sách học viên theo tìm kiếm
    final filteredStudents = students.where((s) {
      return s.hoTen.toLowerCase().contains(searchQuery);
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('STT')),
          DataColumn(label: Text('Họ tên')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Điểm')),
          DataColumn(label: Text('Nhận xét')),
          DataColumn(label: Text('Lưu')),
        ],
        rows: List.generate(filteredStudents.length, (index) {
          final s = filteredStudents[index];
          return DataRow(
            cells: [
              DataCell(Text('${index + 1}')),
              DataCell(
                Text(
                  s.hoTen,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(
                Text(
                  s.email,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: diemControllers[s.id],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Nhập điểm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 300,
                  child: TextFormField(
                    controller: nhanXetControllers[s.id],
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Nhập nhận xét...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              DataCell(
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.save, color: Colors.blue),
                    tooltip: 'Lưu nhận xét',
                    onPressed: isLoading
                        ? null
                        : () => _luuNhanXet(s.id, maLop),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
