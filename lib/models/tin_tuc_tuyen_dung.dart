class TinTucTuyenDung {
  final int maTinTuc;
  final String tieuDeTinTuc;
  final String noiDung;
  final DateTime ngayDang;
  final DateTime ngayKetThuc;
  final String? hinhAnh;

  TinTucTuyenDung({
    required this.maTinTuc,
    required this.tieuDeTinTuc,
    required this.noiDung,
    required this.ngayDang,
    required this.ngayKetThuc,
    this.hinhAnh,
  });

  factory TinTucTuyenDung.fromJson(Map<String, dynamic> json) {
    return TinTucTuyenDung(
      maTinTuc: json['maTinTuc'],
      tieuDeTinTuc: json['tieuDeTinTuc'],
      noiDung: json['noiDung'],
      ngayDang: DateTime.parse(json['ngayDang']),
      ngayKetThuc: DateTime.parse(json['ngayKetThuc']),
      hinhAnh: json['hinhAnh'],
    );
  }
}
