import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import '../models/trang_thai_diem_danh_model.dart';

class StudentDiemDanhService {
  // Lấy trạng thái điểm danh của học sinh cho 1 lớp trong 1 ngày
  static Future<TrangThaiDiemDanh?> getTrangThaiDiemDanh(
    int maLop,
    DateTime ngay,
  ) async {
    final url = Uri.parse(
      "${AuthService.baseUrl}api/StudentHomeApi/GetTrangThaiDiemDanh/$maLop?ngay=${ngay.toIso8601String()}",
    );
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return TrangThaiDiemDanh.fromJson(jsonBody);
      }
      return null;
    } catch (e) {
      print("Error getTrangThaiDiemDanh: $e");
      return null;
    }
  }

  // Parse ngày học từ string "T2,4,6 Sáng" -> [2, 4, 6]
  static List<int> _parseNgayHoc(String ngayHoc) {
    final regex = RegExp(r'T([2-7](?:,\s*[2-7])*)');
    final match = regex.firstMatch(ngayHoc);
    if (match != null) {
      return match
          .group(1)!
          .split(',')
          .map((e) => int.parse(e.trim()))
          .toList();
    }
    return [];
  }

  // Lấy trạng thái điểm danh cho nhiều lớp trong 1 tuần (chỉ check ngày có học)
  static Future<Map<String, TrangThaiDiemDanh>> getTrangThaiDiemDanhTuan(
    List<Map<String, dynamic>> danhSachLop, // Thay đổi: nhận cả object lớp
    DateTime tuanBatDau,
  ) async {
    Map<String, TrangThaiDiemDanh> result = {};

    for (var lop in danhSachLop) {
      final maLop = lop['maLopHoc'] as int;
      final ngayHoc = lop['ngayHoc'] as String;
      final ngayKhaiGiang = lop['ngayKhaiGiang'] as DateTime;
      final ngayKetThuc = lop['ngayKetThuc'] as DateTime;

      // Parse các thứ học (2,4,6)
      final cacThuHoc = _parseNgayHoc(ngayHoc);
      print('Lớp $maLop học các thứ: $cacThuHoc');

      // Chỉ check 6 ngày trong tuần (T2-T7)
      for (int i = 0; i < 6; i++) {
        final ngay = tuanBatDau.add(Duration(days: i));
        final thu = i + 2; // T2=2, T3=3, ..., T7=7

        // Kiểm tra có học ngày này không
        if (!cacThuHoc.contains(thu)) continue;

        // Kiểm tra ngày có nằm trong khoảng khóa học không
        if (ngay.isBefore(ngayKhaiGiang) || ngay.isAfter(ngayKetThuc)) {
          continue;
        }

        print('📡 Gọi API: maLop=$maLop, ngay=${ngay.day}/${ngay.month} (Thứ $thu)');
        final trangThai = await getTrangThaiDiemDanh(maLop, ngay);

        if (trangThai != null) {
          print('Response: DaDiemDanh=${trangThai.daDiemDanh}, CoMat=${trangThai.coMat}');
          if (trangThai.daDiemDanh) {
            final key = '${maLop}_${ngay.day}_${ngay.month}';
            result[key] = trangThai;
            print('Lưu vào map với key: $key');
          }
        } else {
          print('API trả về null');
        }
      }
    }

    print('Tổng kết: ${result.length} records điểm danh');
    return result;
  }
}
