class TeacherHomeData {
  final DateTime weekStart;
  final List<LopDayData> list;

  TeacherHomeData({required this.weekStart, required this.list});

  factory TeacherHomeData.fromJson(Map<String, dynamic> json) {
    return TeacherHomeData(
      weekStart: DateTime.parse(json['weekStart']),
      list: (json['list'] as List).map((e) => LopDayData.fromJson(e)).toList(),
    );
  }
}

class LopDayData {
  final int maLopHoc;
  final String tenKhoaHoc;
  final DateTime ngayKhaiGiang;
  final DateTime ngayKetThuc;
  final String phongHoc;
  final String ngayHoc;
  final String? hinhAnh;

  LopDayData({
    required this.maLopHoc,
    required this.tenKhoaHoc,
    required this.ngayKhaiGiang,
    required this.ngayKetThuc,
    required this.phongHoc,
    required this.ngayHoc,
    this.hinhAnh,
  });

  factory LopDayData.fromJson(Map<String, dynamic> json) {
    return LopDayData(
      maLopHoc: json['maLopHoc'],
      tenKhoaHoc: json['tenKhoaHoc'],
      ngayKhaiGiang: DateTime.parse(json['ngayKhaiGiang']),
      ngayKetThuc: DateTime.parse(json['ngayKetThuc']),
      phongHoc: json['phongHoc'],
      ngayHoc: json['ngayHoc'],
      hinhAnh: json['hinhAnh'],
    );
  }
}
