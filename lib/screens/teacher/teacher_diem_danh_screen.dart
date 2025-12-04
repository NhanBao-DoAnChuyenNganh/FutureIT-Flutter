import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/diem_danh_model.dart';
import '../../services/teacher_home_service.dart';

class TeacherDiemDanhScreen extends StatefulWidget {
  final int maLop;
  final String tenKhoaHoc;
  final DateTime? ngayDiemDanh;

  const TeacherDiemDanhScreen({
    super.key,
    required this.maLop,
    required this.tenKhoaHoc,
    this.ngayDiemDanh,
  });

  @override
  State<TeacherDiemDanhScreen> createState() => _TeacherDiemDanhScreenState();
}

class _TeacherDiemDanhScreenState extends State<TeacherDiemDanhScreen> {
  late DateTime selectedDate;
  late Future<DiemDanhData?> _futureData;
  Map<String, bool> diemDanhStatus = {};
  Map<String, TextEditingController> ghiChuControllers = {};
  bool isLoading = false;

  // Danh sách tên thứ tiếng Việt
  final List<String> weekdayNames = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ Nhật',
  ];

  String _formatDate(DateTime date) {
    final weekday = weekdayNames[date.weekday - 1];
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - $weekday';
  }

  @override
  void initState() {
    super.initState();
    selectedDate = widget.ngayDiemDanh ?? DateTime.now();
    _loadDiemDanh();
  }

  @override
  void dispose() {
    ghiChuControllers.forEach((_, ctrl) => ctrl.dispose());
    super.dispose();
  }

  void _loadDiemDanh() {
    setState(() {
      _futureData = TeacherHomeService.getDiemDanhTheoNgay(
        widget.maLop,
        selectedDate,
      );
    });
  }

  void _initControllers(List<HocVienDiemDanh> students) {
    for (var s in students) {
      if (!diemDanhStatus.containsKey(s.id)) {
        diemDanhStatus[s.id] = s.diemDanh?.coMat ?? false;
        ghiChuControllers[s.id] = TextEditingController(
          text: s.diemDanh?.ghiChu ?? '',
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade800,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        diemDanhStatus.clear();
        ghiChuControllers.forEach((_, ctrl) => ctrl.dispose());
        ghiChuControllers.clear();
      });
      _loadDiemDanh();
    }
  }

  Future<void> _luuDiemDanh() async {
    final danhSach = diemDanhStatus.entries.map((entry) {
      return {
        'UserId': entry.key,
        'CoMat': entry.value,
        'GhiChu': ghiChuControllers[entry.key]?.text ?? '',
      };
    }).toList();

    setState(() => isLoading = true);

    final success = await TeacherHomeService.luuDiemDanhHangLoat(
      maLop: widget.maLop,
      ngayDiemDanh: selectedDate,
      danhSach: danhSach,
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? '✅ Lưu điểm danh thành công' : '❌ Lưu thất bại'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      _loadDiemDanh();
    }
  }

  void _toggleAll(bool value) {
    setState(() {
      for (var key in diemDanhStatus.keys) {
        diemDanhStatus[key] = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Điểm danh',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.tenKhoaHoc,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date Picker Card
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngày điểm danh',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: const Text('Chọn ngày'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Student List
          Expanded(
            child: FutureBuilder<DiemDanhData?>(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(
                    child: Text('Không thể tải dữ liệu'),
                  );
                }

                final data = snapshot.data!;
                _initControllers(data.danhSach);

                if (data.danhSach.isEmpty) {
                  return const Center(
                    child: Text('Không có học viên nào'),
                  );
                }

                return Column(
                  children: [
                    // Quick Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Tổng: ${data.danhSach.length} học viên',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () => _toggleAll(true),
                            icon: const Icon(Icons.check_circle, size: 18),
                            label: const Text('Tất cả có mặt'),
                          ),
                          TextButton.icon(
                            onPressed: () => _toggleAll(false),
                            icon: const Icon(Icons.cancel, size: 18),
                            label: const Text('Tất cả vắng'),
                          ),
                        ],
                      ),
                    ),

                    // List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: data.danhSach.length,
                        itemBuilder: (context, index) {
                          final student = data.danhSach[index];
                          final isPresent = diemDanhStatus[student.id] ?? false;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      // Avatar
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundImage: student.avatar != null
                                            ? NetworkImage(student.avatar!)
                                            : null,
                                        backgroundColor: Colors.blue.shade100,
                                        child: student.avatar == null
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),

                                      // Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student.hoTen,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            Text(
                                              student.email,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Checkbox
                                      Checkbox(
                                        value: isPresent,
                                        onChanged: (value) {
                                          setState(() {
                                            diemDanhStatus[student.id] =
                                                value ?? false;
                                          });
                                        },
                                        activeColor: Colors.green,
                                      ),
                                      Text(
                                        isPresent ? 'Có mặt' : 'Vắng',
                                        style: TextStyle(
                                          color: isPresent
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Ghi chú
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: ghiChuControllers[student.id],
                                    decoration: InputDecoration(
                                      hintText: 'Ghi chú (tùy chọn)',
                                      prefixIcon: const Icon(
                                        Icons.note,
                                        size: 18,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      isDense: true,
                                    ),
                                    style: const TextStyle(fontSize: 13),
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
              },
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _luuDiemDanh,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(isLoading ? 'Đang lưu...' : 'Lưu điểm danh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
