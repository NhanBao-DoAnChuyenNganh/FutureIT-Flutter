
import 'danh_gia_model.dart';

class ChiTietKhoaHoc {
  final int maKhoaHoc;
  final String tenKhoaHoc;
  final String ngayHoc;
  final String gioBatDau;
  final String gioKetThuc;
  final double hocPhi;
  final String moTa;
  final bool daYeuThich;
  final double soSaoTrungBinh;
  final int tongLuotDanhGia;
  final List<String> hinhAnh;
  final List<DanhGiaModel> danhGia;

  ChiTietKhoaHoc({
    required this.maKhoaHoc,
    required this.tenKhoaHoc,
    required this.ngayHoc,
    required this.gioBatDau,
    required this.gioKetThuc,
    required this.hocPhi,
    required this.moTa,
    required this.daYeuThich,
    required this.soSaoTrungBinh,
    required this.tongLuotDanhGia,
    required this.hinhAnh,
    required this.danhGia,
  });

  factory ChiTietKhoaHoc.fromJson(Map<String, dynamic> json) {
    return ChiTietKhoaHoc(
      maKhoaHoc: json['maKhoaHoc'],
      tenKhoaHoc: json['tenKhoaHoc'],
      ngayHoc: json['ngayHoc'],
      gioBatDau: json['gioBatDau'] ?? "",
      gioKetThuc: json['gioKetThuc'] ?? "",
      hocPhi: (json['hocPhi'] as num).toDouble(),
      moTa: json['moTa'] ?? "",
      daYeuThich: json['daYeuThich'] ?? false,
      soSaoTrungBinh: (json['soSaoTrungBinh'] as num?)?.toDouble() ?? 0.0,
      tongLuotDanhGia: json['tongLuotBinhLuan'] ?? 0,
      hinhAnh: List<String>.from(json['hinhAnh'] ?? []),
      danhGia: (json['danhGia'] as List<dynamic>? ?? [])
          .map((e) => DanhGiaModel.fromJson(e))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'maKhoaHoc': maKhoaHoc,
      'tenKhoaHoc': tenKhoaHoc,
      'ngayHoc': ngayHoc,
      'gioBatDau': gioBatDau,
      'gioKetThuc': gioKetThuc,
      'hocPhi': hocPhi,
      'moTa': moTa,
      'daYeuThich': daYeuThich,
      'soSaoTrungBinh': soSaoTrungBinh,
      'tongLuotBinhLuan': tongLuotDanhGia,
      'hinhAnh': hinhAnh,
      'danhGia': danhGia.map((e) => e.toJson()).toList(),
    };
  }

}
