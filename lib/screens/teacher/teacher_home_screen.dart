import 'package:do_an_chuyen_nganh/screens/teacher/teacher_class_detail_screen.dart';
import 'package:do_an_chuyen_nganh/screens/teacher/teacher_diem_danh_screen.dart';
import 'package:do_an_chuyen_nganh/screens/student/dashboard_screen.dart';
import 'package:do_an_chuyen_nganh/services/auth_service.dart';
import 'package:do_an_chuyen_nganh/widgets/user_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/teacher_home_model.dart';
import '../../services/teacher_home_service.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // USER
  Map<String, String> userData = {};
  String avatarBase64 = '';
  bool isLoggedIn = false;

  // DATA
  late Future<TeacherHomeData?> _futureData;
  DateTime currentWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _loadUser();
    currentWeekStart = _getStartOfWeek(DateTime.now());
    _futureData = TeacherHomeService.getLopDangDay(startDate: currentWeekStart);
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
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
        (route) => false,
      );
    }
  }

  // ---------------------------
  // LỊCH HỌC - XỬ LÝ TUẦN
  // ---------------------------
  DateTime _getStartOfWeek(DateTime date) {
    int offset = date.weekday == DateTime.sunday ? -6 : 1 - date.weekday;
    return date.add(Duration(days: offset));
  }

  void _previousWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.subtract(const Duration(days: 7));
      _futureData = TeacherHomeService.getLopDangDay(
        startDate: currentWeekStart,
      );
    });
  }

  void _nextWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
      _futureData = TeacherHomeService.getLopDangDay(
        startDate: currentWeekStart,
      );
    });
  }

  // ---------------------------
  // BUILD - THỜI KHÓA BIỂU GRID
  // ---------------------------
  Widget _buildScheduleListView(TeacherHomeData data) {
    if (data.list.isEmpty) {
      return const Center(child: Text('Bạn không có lớp nào đang dạy'));
    }

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
                onPressed: _previousWeek,
              ),
              Text(
                'Tuần: '
                    '${currentWeekStart.day}/${currentWeekStart.month} - '
                    '${currentWeekStart.add(const Duration(days: 6)).day}/${currentWeekStart.add(const Duration(days: 6)).month}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextWeek,
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
                      Text(
                        'Thứ $displayThu (${day.day}/${day.month})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 6),

                      for (var ca in caHocList)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ca,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),

                            // FIlter các lớp đúng ngày & ca
                            ...data.list.where((item) {
                              if (item.ngayKhaiGiang.isAfter(day) ||
                                  item.ngayKetThuc.isBefore(day)) {
                                return false;
                              }

                              // Check Ca học (Sáng/Chiều)
                              if (!item.ngayHoc.toLowerCase().contains(
                                ca.toLowerCase(),
                              )) return false;

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
                            }).map(
                                  (item) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TeacherClassDetailScreen(maLop: item.maLopHoc),
                                      ),
                                    );
                                  },
                                  onLongPress: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(Icons.info, color: Colors.blue),
                                              title: const Text('Xem chi tiết lớp'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => TeacherClassDetailScreen(maLop: item.maLopHoc),
                                                  ),
                                                );
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.checklist, color: Colors.green),
                                              title: const Text('Điểm danh'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => TeacherDiemDanhScreen(
                                                      maLop: item.maLopHoc,
                                                      tenKhoaHoc: item.tenKhoaHoc,
                                                      ngayDiemDanh: day,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },

                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.tenKhoaHoc,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Phòng: ${item.phongHoc}',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
  }


  // ---------------------------
  // BUILD - DANH SÁCH LỚP
  // ---------------------------
  Widget _buildClassList(TeacherHomeData data) {
    if (data.list.isEmpty) {
      return const Center(child: Text('Bạn không có lớp nào đang dạy'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: data.list.length,
      itemBuilder: (context, index) {
        final item = data.list[index];

        // Tính tiến độ lớp học
        final duration = item.ngayKetThuc.difference(item.ngayKhaiGiang).inDays;
        final elapsed = DateTime.now().difference(item.ngayKhaiGiang).inDays;
        final percent = (elapsed / duration * 100).clamp(0, 100).toInt();

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER: Tên khóa học + lịch học
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.tenKhoaHoc,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lịch: ${item.ngayHoc}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // THÔNG TIN THÊM
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Giờ học:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          // Giờ học từ API không có sẵn, có thể lấy từ ngayHoc
                          Text(
                            '${item.ngayHoc}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thời gian:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            '${item.ngayKhaiGiang.day}/${item.ngayKhaiGiang.month} - '
                            '${item.ngayKetThuc.day}/${item.ngayKetThuc.month}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // PROGRESS BAR
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 24,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(
                      percent > 80
                          ? Colors.orange
                          : percent > 50
                          ? Colors.blue
                          : Colors.green,
                    ),
                    semanticsLabel: '$percent%',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tiến độ: $percent%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeacherClassDetailScreen(maLop: item.maLopHoc),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                    ),
                    child: const Text(
                      'Xem chi tiết lớp',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          tabs: const [
            Tab(
              child: SizedBox(
                width: 150,
                child: Center(child: Text('🗓️ Thời khóa biểu')),
              ),
            ),
            Tab(
              child: SizedBox(
                width: 150,
                child: Center(child: Text('📋 Danh sách lớp')),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<TeacherHomeData?>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Không thể tải dữ liệu'));
          }

          final data = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildScheduleListView(data),
              _buildClassList(data),],
          );
        },
      ),
    );
  }
}
