class KhoaHocDaDangKyResponse {
  final List<KhoaHocDaDangKy> listPhieuDangKy; // Chờ xếp lớp
  final List<KhoaHocDangHoc> listDangHoc;      // Đang học
  final List<KhoaHocDaHoc> listDaHoc;          // Đã học
  final List<KhoaHocConNo> listConNo;          // Chưa thanh toán hết

  KhoaHocDaDangKyResponse({
    required this.listPhieuDangKy,
    required this.listDangHoc,
    required this.listDaHoc,
    required this.listConNo,
  });

  factory KhoaHocDaDangKyResponse.fromJson(Map<String, dynamic> json) {
    return KhoaHocDaDangKyResponse(
      listPhieuDangKy: (json['listPhieuDangKy'] as List)
          .map((e) => KhoaHocDaDangKy.fromJson(e))
          .toList(),
      listDangHoc: (json['listDangHoc'] as List)
          .map((e) => KhoaHocDangHoc.fromJson(e))
          .toList(),
      listDaHoc: (json['listDaHoc'] as List)
          .map((e) => KhoaHocDaHoc.fromJson(e))
          .toList(),
      listConNo: (json['listConNo'] as List)
          .map((e) => KhoaHocConNo.fromJson(e))
          .toList(),
    );
  }
}

// ------------------ Chờ xếp lớp ------------------
class KhoaHocDaDangKy {
  final int maKhoaHoc;
  final String tenKhoaHoc;
  final String trangThaiDangKy;
  final String trangThaiThanhToan;
  final String hinhAnh;

  KhoaHocDaDangKy({
    required this.maKhoaHoc,
    required this.tenKhoaHoc,
    required this.trangThaiDangKy,
    required this.trangThaiThanhToan,
    required this.hinhAnh,
  });

  factory KhoaHocDaDangKy.fromJson(Map<String, dynamic> json) {
    return KhoaHocDaDangKy(
      maKhoaHoc: json['maKhoaHoc'],
      tenKhoaHoc: json['tenKhoaHoc'],
      trangThaiDangKy: json['trangThaiDangKy'],
      trangThaiThanhToan: json['trangThaiThanhToan'],
      hinhAnh: json['hinhAnh'],
    );
  }
}

// ------------------ Đang học ------------------
class KhoaHocDangHoc {
  final int maLopHoc;
  final String tenKhoaHoc;
  final DateTime ngayKhaiGiang;
  final DateTime ngayKetThuc;
  final String phongHoc;
  final String ngayHoc; // mới: "Sáng 2,4,6"

  KhoaHocDangHoc({
    required this.maLopHoc,
    required this.tenKhoaHoc,
    required this.ngayKhaiGiang,
    required this.ngayKetThuc,
    required this.phongHoc,
    required this.ngayHoc,
  });

  factory KhoaHocDangHoc.fromJson(Map<String, dynamic> json) {
    return KhoaHocDangHoc(
      maLopHoc: json['maLopHoc'],
      tenKhoaHoc: json['tenKhoaHoc'],
      ngayKhaiGiang: DateTime.parse(json['ngayKhaiGiang']),
      ngayKetThuc: DateTime.parse(json['ngayKetThuc']),
      phongHoc: json['phongHoc'],
      ngayHoc: json['ngayHoc'], // lấy trực tiếp từ API
    );
  }
}

// ------------------ Đã học ------------------
class KhoaHocDaHoc {
  final int maLopHoc;
  final String tenKhoaHoc;
  final DateTime ngayKhaiGiang;
  final DateTime ngayKetThuc;
  final String hinhAnh;
  final String? nhanXetCuaGiaoVien;
  final double? diemTongKet;

  KhoaHocDaHoc({
    required this.maLopHoc,
    required this.tenKhoaHoc,
    required this.ngayKhaiGiang,
    required this.ngayKetThuc,
    required this.hinhAnh,
    this.nhanXetCuaGiaoVien,
    this.diemTongKet,
  });

  factory KhoaHocDaHoc.fromJson(Map<String, dynamic> json) {
    return KhoaHocDaHoc(
      maLopHoc: json['maLopHoc'],
      tenKhoaHoc: json['tenKhoaHoc'],
      ngayKhaiGiang: DateTime.parse(json['ngayKhaiGiang']),
      ngayKetThuc: DateTime.parse(json['ngayKetThuc']),
      hinhAnh: json['hinhAnh'],
      nhanXetCuaGiaoVien: json['nhanXetCuaGiaoVien'],
      diemTongKet: json['diemTongKet'] != null ? (json['diemTongKet'] as num).toDouble() : null,
    );
  }
}

// ------------------ Chưa thanh toán hết ------------------
class KhoaHocConNo {
  final int maKhoaHoc;
  final String tenKhoaHoc;
  final int hocPhi;
  final int tienDongLan1;
  final String hinhAnh;

  KhoaHocConNo({
    required this.maKhoaHoc,
    required this.tenKhoaHoc,
    required this.hocPhi,
    required this.tienDongLan1,
    required this.hinhAnh,
  });

  factory KhoaHocConNo.fromJson(Map<String, dynamic> json) {
    return KhoaHocConNo(
      maKhoaHoc: json['maKhoaHoc'],
      tenKhoaHoc: json['tenKhoaHoc'],
      hocPhi: json['hocPhi'],
      tienDongLan1: json['tienDongLan1'],
      hinhAnh: json['hinhAnh'],
    );
  }
}
