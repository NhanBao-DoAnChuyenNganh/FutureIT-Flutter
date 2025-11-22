class KhoaHoc {
  final int maKhoaHoc;
  final String tenKhoaHoc;
  final String ngayHoc;
  final double hocPhi;
  final bool daYeuThich;
  final int? tongLuotQuanTam;
  final int? tongLuotBinhLuan;
  final double? soSaoTrungBinh;
  final String? hinhAnhUrl;

  KhoaHoc({
    required this.maKhoaHoc,
    required this.tenKhoaHoc,
    required this.ngayHoc,
    required this.hocPhi,
    required this.daYeuThich,
    this.tongLuotQuanTam,
    this.tongLuotBinhLuan,
    this.soSaoTrungBinh,
    this.hinhAnhUrl,
  });

  factory KhoaHoc.fromJson(Map<String, dynamic> json) {
    return KhoaHoc(
      maKhoaHoc: json['maKhoaHoc'] ?? 0,
      tenKhoaHoc: json['tenKhoaHoc'] ?? '',
      ngayHoc: json['ngayHoc'] ?? '',
      hocPhi: (json['hocPhi'] as num?)?.toDouble() ?? 0.0,
      daYeuThich: json['daYeuThich'] ?? false,
      tongLuotQuanTam: json['tongLuotQuanTam'] ?? 0,
      tongLuotBinhLuan: json['tongLuotBinhLuan'] ?? 0,
      soSaoTrungBinh: (json['soSaoTrungBinh'] as num?)?.toDouble() ?? 0.0,
      hinhAnhUrl: json['hinhAnh'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maKhoaHoc': maKhoaHoc,
      'tenKhoaHoc': tenKhoaHoc,
      'ngayHoc': ngayHoc,
      'hocPhi': hocPhi,
      'daYeuThich': daYeuThich,
      'tongLuotQuanTam': tongLuotQuanTam,
      'tongLuotBinhLuan': tongLuotBinhLuan,
      'soSaoTrungBinh': soSaoTrungBinh,
      'hinhAnh': hinhAnhUrl,
    };
  }
  KhoaHoc copyWith({
    bool? daYeuThich,
    int? tongLuotQuanTam,
  }) {
    return KhoaHoc(
      maKhoaHoc: maKhoaHoc,
      tenKhoaHoc: tenKhoaHoc,
      ngayHoc: ngayHoc,
      hocPhi: hocPhi,
      daYeuThich: daYeuThich ?? this.daYeuThich,
      tongLuotQuanTam: tongLuotQuanTam ?? this.tongLuotQuanTam,
      tongLuotBinhLuan: tongLuotBinhLuan,
      soSaoTrungBinh: soSaoTrungBinh,
      hinhAnhUrl: hinhAnhUrl,
    );
  }
}
