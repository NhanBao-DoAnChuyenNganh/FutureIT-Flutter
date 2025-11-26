class StudentHomeData {
  final News? tinMoi1;
  final News? tinMoi2;
  final List<Course> list3KhoaHocPhoBien;
  final Teacher? gvtb1;
  final Teacher? gvtb2;
  final Teacher? gvtb3;
  final Teacher? gvtb4;

  StudentHomeData({
    required this.tinMoi1,
    required this.tinMoi2,
    required this.list3KhoaHocPhoBien,
    required this.gvtb1,
    required this.gvtb2,
    required this.gvtb3,
    required this.gvtb4,
  });

  factory StudentHomeData.fromJson(Map<String, dynamic> json) {
    return StudentHomeData(
      tinMoi1: json['tinMoi1'] != null ? News.fromJson(json['tinMoi1']) : null,
      tinMoi2: json['tinMoi2'] != null ? News.fromJson(json['tinMoi2']) : null,
      list3KhoaHocPhoBien: (json['list3KhoaHocPhoBien'] as List)
          .map((e) => Course.fromJson(e))
          .toList(),
      gvtb1: json['gvtb1'] != null ? Teacher.fromJson(json['gvtb1']) : null,
      gvtb2: json['gvtb2'] != null ? Teacher.fromJson(json['gvtb2']) : null,
      gvtb3: json['gvtb3'] != null ? Teacher.fromJson(json['gvtb3']) : null,
      gvtb4: json['gvtb4'] != null ? Teacher.fromJson(json['gvtb4']) : null,
    );
  }
}

class News {
  final String tieuDeTinTuc;
  final String noiDungTinTuc;
  final String ngayDang;
  final String hinhTinTuc;

  News({
    required this.tieuDeTinTuc,
    required this.noiDungTinTuc,
    required this.ngayDang,
    required this.hinhTinTuc,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      tieuDeTinTuc: json['tieuDeTinTuc'],
      noiDungTinTuc: json['noiDungTinTuc'],
      ngayDang: json['ngayDang'],
      hinhTinTuc: (json['hinhTinTuc'] ?? "").toString().trim(),
    );
  }
}

class Course {
  final String tenKhoaHoc;
  final String moTa;
  final double hocPhi;
  final String hinhAnh;

  Course({
    required this.tenKhoaHoc,
    required this.moTa,
    required this.hocPhi,
    required this.hinhAnh,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      tenKhoaHoc: json['tenKhoaHoc'],
      moTa: json['moTa'],
      hocPhi: (json['hocPhi'] as num).toDouble(),
      hinhAnh: (json['hinhAnh'] ?? "").toString().trim(),
    );
  }
}

class Teacher {
  final String hoTen;
  final String email;
  final String avatar;
  final String chuyenNganh;

  Teacher({
    required this.hoTen,
    required this.email,
    required this.avatar,
    required this.chuyenNganh,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      hoTen: json['hoTen'],
      email: json['email'],
      avatar: (json['avatar'] ?? "").toString().trim(),
      chuyenNganh: json['chuyenNganh'] ?? "",
    );
  }
}
