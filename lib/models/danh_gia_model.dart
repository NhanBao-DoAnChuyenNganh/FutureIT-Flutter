class DanhGiaModel {
  final int maDanhGia;
  final String user;
  final String avatarBase64;
  final int soSaoDanhGia;
  final String noiDungDanhGia;
  final String ngayDanhGia;

  DanhGiaModel({
    required this.maDanhGia,
    required this.user,
    required this.avatarBase64,
    required this.soSaoDanhGia,
    required this.noiDungDanhGia,
    required this.ngayDanhGia,
  });

  factory DanhGiaModel.fromJson(Map<String, dynamic> json) {
    return DanhGiaModel(
      maDanhGia: json['maDanhGia'],
      user: json['user'] ?? "",
      avatarBase64: json['avatar'] ?? "",
      soSaoDanhGia: json['soSaoDanhGia'],
      noiDungDanhGia: json['noiDungDanhGia'] ?? "",
      ngayDanhGia: json['ngayDanhGia'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'maDanhGia': maDanhGia,
      'user': user,
      'avatar': avatarBase64,
      'soSaoDanhGia': soSaoDanhGia,
      'noiDungDanhGia': noiDungDanhGia,
      'ngayDanhGia': ngayDanhGia,
    };
  }

}
