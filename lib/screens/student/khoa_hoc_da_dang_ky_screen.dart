import 'package:flutter/material.dart';
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
  late Future<KhoaHocDaDangKyResponse> _futureData;
  DateTime currentWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _futureData = KhoaHocDaDangKyService.getKhoaHocDaDangKy();
    currentWeekStart = getStartOfWeek(DateTime.now());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DateTime getStartOfWeek(DateTime date) {
    int offset = date.weekday == DateTime.sunday ? -6 : 1 - date.weekday;
    return date.add(Duration(days: offset));
  }

  Widget buildTabContent(KhoaHocDaDangKyResponse data, int tabIndex) {
    switch (tabIndex) {
      case 0: // Chờ xếp lớp
        final list = data.listPhieuDangKy;
        if (list.isEmpty) return const Center(child: Text('Bạn chưa có khóa học chờ xử lý.'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, index) {
            final item = list[index];
            return Card(
              child: ListTile(
                leading: Image.network(item.hinhAnh, width: 80, height: 60, fit: BoxFit.cover),
                title: Text(item.tenKhoaHoc),
                subtitle: Text('Trạng thái: ${item.trangThaiThanhToan}'),
                trailing: const Text('Chờ xếp lớp', style: TextStyle(color: Colors.orange)),
              ),
            );
          },
        );

      case 1: // Đang học (Thời khóa biểu tuần)
        final list = data.listDangHoc;
        if (list.isEmpty) return const Center(child: Text('Bạn không có khóa học đang học.'));

        List<String> caHocList = ['Sáng', 'Chiều'];

        return Column(
          children: [
            // Tuần navigation
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        currentWeekStart = currentWeekStart.subtract(const Duration(days: 7));
                      });
                    },
                  ),
                  Text(
                    'Tuần: ${currentWeekStart.day}/${currentWeekStart.month}/${currentWeekStart.year} - ${currentWeekStart.add(const Duration(days: 6)).day}/${currentWeekStart.add(const Duration(days: 6)).month}/${currentWeekStart.add(const Duration(days: 6)).year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        currentWeekStart = currentWeekStart.add(const Duration(days: 7));
                      });
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: 6, // Thứ 2 → Thứ 7
                itemBuilder: (context, i) {
                  final day = currentWeekStart.add(Duration(days: i));
                  final displayThu = i + 2; // i=0 → Thứ 2, i=5 → Thứ 7

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ngày
                          Text(
                            'Thứ $displayThu (${day.day}/${day.month})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),

                          // 2 ca học: Sáng / Chiều
                          for (var ca in caHocList)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ca, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  ...list.where((item) {
                                    // Kiểm tra tuần
                                    if (item.ngayKhaiGiang.isAfter(day) || item.ngayKetThuc.isBefore(day)) return false;

                                    // Kiểm tra ca học
                                    if (!item.ngayHoc.toLowerCase().contains(ca.toLowerCase())) return false;

                                    // Kiểm tra thứ
                                    final regex = RegExp(r'T([2-7](?:, *[2-7])*)'); // T2,4,6
                                    final match = regex.firstMatch(item.ngayHoc);
                                    if (match != null) {
                                      final listThu = match.group(1)!.split(',').map((e) => int.parse(e.trim())).toList();
                                      if (!listThu.contains(displayThu)) return false;
                                    }

                                    return true;
                                  }).map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      '${item.tenKhoaHoc} - Phòng: ${item.phongHoc}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  )),
                                ],
                              ),
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

      case 2: // Còn nợ học phí
        final list = data.listConNo;
        if (list.isEmpty) return const Center(child: Text('Bạn không còn nợ học phí.'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, index) {
            final item = list[index];
            final conNo = item.hocPhi - item.tienDongLan1;
            return Card(
              child: ListTile(
                leading: Image.network(item.hinhAnh, width: 80, height: 60, fit: BoxFit.cover),
                title: Text(item.tenKhoaHoc),
                subtitle: Text('Còn nợ: $conNo VND'),
              ),
            );
          },
        );

      case 3: // Đã học
        final list = data.listDaHoc;
        if (list.isEmpty) return const Center(child: Text('Bạn chưa hoàn thành khóa học nào.'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, index) {
            final item = list[index];
            return Card(
              child: ListTile(
                leading: Image.network(item.hinhAnh, width: 80, height: 60, fit: BoxFit.cover),
                title: Text(item.tenKhoaHoc),
                subtitle: Text(
                    'Điểm: ${item.diemTongKet ?? '-'}\nNhận xét: ${item.nhanXetCuaGiaoVien ?? '-'}\nThời gian: ${item.ngayKhaiGiang.day}/${item.ngayKhaiGiang.month}/${item.ngayKhaiGiang.year} - ${item.ngayKetThuc.day}/${item.ngayKetThuc.month}/${item.ngayKetThuc.year}'),
              ),
            );
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khóa học đã đăng ký'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Chờ xếp lớp'),
            Tab(text: 'Đang học'),
            Tab(text: 'Còn nợ'),
            Tab(text: 'Đã học'),
          ],
        ),
      ),
      body: FutureBuilder<KhoaHocDaDangKyResponse>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Không có dữ liệu'));
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
