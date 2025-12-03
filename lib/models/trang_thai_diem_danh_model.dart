class TrangThaiDiemDanh {
  final DateTime ngayDiemDanh;
  final bool daDiemDanh;
  final bool coMat;
  final String? ghiChu;

  TrangThaiDiemDanh({
    required this.ngayDiemDanh,
    required this.daDiemDanh,
    required this.coMat,
    this.ghiChu,
  });

  factory TrangThaiDiemDanh.fromJson(Map<String, dynamic> json) {
    return TrangThaiDiemDanh(
      ngayDiemDanh: DateTime.parse(json['ngayDiemDanh']),
      daDiemDanh: json['daDiemDanh'] ?? false,
      coMat: json['coMat'] ?? false,
      ghiChu: json['ghiChu'],
    );
  }
}
