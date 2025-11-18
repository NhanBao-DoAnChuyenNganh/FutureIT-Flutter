class User {
  final String token;
  final DateTime expires;
  final List<String> roles;
  final String email;
  final String username;
  final String sdt;
  final String diaChi;
  final String ngayDK;
  final String avatarBase64;
  final bool isApproved;

  User({
    required this.token,
    required this.expires,
    required this.roles,
    required this.email,
    required this.username,
    required this.sdt,
    required this.diaChi,
    required this.ngayDK,
    required this.avatarBase64,
    required this.isApproved,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'] ?? '',
      expires: DateTime.parse(json['expires']),
      roles: List<String>.from(json['roles'] ?? []),
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      sdt: json['sdt'] ?? '',
      diaChi: json['diaChi'] ?? '',
      ngayDK: json['ngayDK'] ?? '',
      avatarBase64: json['avatarBase64'] ?? '',
      isApproved: json['isApproved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expires': expires.toIso8601String(),
      'roles': roles,
      'email': email,
      'username': username,
      'sdt': sdt,
      'diaChi': diaChi,
      'ngayDK': ngayDK,
      'avatarBase64': avatarBase64,
      'isApproved': isApproved,
    };
  }
}
