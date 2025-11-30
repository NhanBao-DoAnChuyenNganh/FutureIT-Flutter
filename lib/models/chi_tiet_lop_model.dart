class ChiTietLop {
  final LopInfo lop;
  final List<HocVienInfo> danhSachHocVien;

  ChiTietLop({required this.lop, required this.danhSachHocVien});

  factory ChiTietLop.fromJson(Map<String, dynamic> json) {
    return ChiTietLop(
      lop: LopInfo.fromJson(json['lop'] ?? {}),
      danhSachHocVien: (json['danhSachHocVien'] as List?)
          ?.map((e) => HocVienInfo.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class LopInfo {
  final int maLopHoc;
  final DateTime ngayKhaiGiang;
  final DateTime ngayKetThuc;
  final String tenPhongHoc;
  final String tenKhoaHoc;
  final String? hinhAnh;

  LopInfo({
    required this.maLopHoc,
    required this.ngayKhaiGiang,
    required this.ngayKetThuc,
    required this.tenPhongHoc,
    required this.tenKhoaHoc,
    this.hinhAnh,
  });

  factory LopInfo.fromJson(Map<String, dynamic> json) {
    return LopInfo(
      maLopHoc: json['maLopHoc'] ?? 0,
      ngayKhaiGiang: json['ngayKhaiGiang'] != null
          ? DateTime.parse(json['ngayKhaiGiang'].toString())
          : DateTime.now(),
      ngayKetThuc: json['ngayKetThuc'] != null
          ? DateTime.parse(json['ngayKetThuc'].toString())
          : DateTime.now(),
      tenPhongHoc: json['tenPhongHoc'] ?? 'N/A',
      tenKhoaHoc: json['tenKhoaHoc'] ?? 'N/A',
      hinhAnh: json['hinhAnh'],
    );
  }
}

class HocVienInfo {
  final String id;
  final String hoTen;
  final String email;
  final String? avatar;
  final String? nhanXetCuaGiaoVien;
  final int? diemTongKet;

  HocVienInfo({
    required this.id,
    required this.hoTen,
    required this.email,
    this.avatar,
    this.nhanXetCuaGiaoVien,
    this.diemTongKet,
  });

  factory HocVienInfo.fromJson(Map<String, dynamic> json) {
    return HocVienInfo(
      id: json['id'] ?? '',
      hoTen:  json['hoTen'] ?? 'N/A',
      email:  json['email'] ?? '',
      avatar: json['avatar'],
      nhanXetCuaGiaoVien:
          json['nhanXetCuaGiaoVien'],
      diemTongKet: json['diemTongKet'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hoTen': hoTen,
      'email': email,
      'avatar': avatar,
      'nhanXetCuaGiaoVien': nhanXetCuaGiaoVien,
      'diemTongKet': diemTongKet,
    };
  }
}
