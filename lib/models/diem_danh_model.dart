class DiemDanhData {
  final DateTime ngayDiemDanh;
  final List<HocVienDiemDanh> danhSach;

  DiemDanhData({
    required this.ngayDiemDanh,
    required this.danhSach,
  });

  factory DiemDanhData.fromJson(Map<String, dynamic> json) {
    return DiemDanhData(
      ngayDiemDanh: DateTime.parse(json['ngayDiemDanh']),
      danhSach: (json['danhSach'] as List)
          .map((e) => HocVienDiemDanh.fromJson(e))
          .toList(),
    );
  }
}

class HocVienDiemDanh {
  final String id;
  final String hoTen;
  final String email;
  final String? avatar;
  final DiemDanhInfo? diemDanh;

  HocVienDiemDanh({
    required this.id,
    required this.hoTen,
    required this.email,
    this.avatar,
    this.diemDanh,
  });

  factory HocVienDiemDanh.fromJson(Map<String, dynamic> json) {
    return HocVienDiemDanh(
      id: json['id'] ?? '',
      hoTen: json['hoTen'] ?? 'N/A',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      diemDanh: json['diemDanh'] != null
          ? DiemDanhInfo.fromJson(json['diemDanh'])
          : null,
    );
  }
}

class DiemDanhInfo {
  final int maDiemDanh;
  final bool coMat;
  final String? ghiChu;

  DiemDanhInfo({
    required this.maDiemDanh,
    required this.coMat,
    this.ghiChu,
  });

  factory DiemDanhInfo.fromJson(Map<String, dynamic> json) {
    return DiemDanhInfo(
      maDiemDanh: json['maDiemDanh'] ?? 0,
      coMat: json['coMat'] ?? false,
      ghiChu: json['ghiChu'],
    );
  }
}
