class Teacher {
  final String hoTen;
  final String diaChi;
  final String avatar;
  final String chuyenNganh;

  Teacher({
    required this.hoTen,
    required this.diaChi,
    required this.avatar,
    required this.chuyenNganh,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      hoTen: json['hoTen'] ?? '',
      diaChi: json['diaChi'] ?? '',
      avatar: json['avatar'] ?? '',
      chuyenNganh: json['chuyenNganh'] ?? 'Chưa cập nhật',
    );
  }
  Map<String, dynamic> toJson() => {
    'hoTen': hoTen,
    'diaChi': diaChi,
    'avatar': avatar,
    'chuyenNganh': chuyenNganh,
  };
}
