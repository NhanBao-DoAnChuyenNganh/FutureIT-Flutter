import 'dart:convert';
import 'package:do_an_chuyen_nganh/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/teacher_home_model.dart';
import '../models/chi_tiet_lop_model.dart';

class TeacherHomeService {
  // 📚 Lấy danh sách lớp đang dạy
  static Future<TeacherHomeData?> getLopDangDay({DateTime? startDate}) async {
    final url = Uri.parse(
      "${AuthService.baseUrl}api/TeacherHomeApi/GetLopDangDay"
      "${startDate != null ? '?startDate=${startDate.toIso8601String()}' : ''}",
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
        return TeacherHomeData.fromJson(jsonBody);
      }
      return null;
    } catch (e) {
      print("Error getLopDangDay: $e");
      return null;
    }
  }

  // 📖 Lấy chi tiết 1 lớp + danh sách học viên
  static Future<ChiTietLop?> getChiTietLop(int maLop) async {
    final url = Uri.parse(
      "${AuthService.baseUrl}api/TeacherHomeApi/GetChiTietLop/$maLop",
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      print('Fetching: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        // API có thể trả về dữ liệu trực tiếp hoặc wrapped trong 'data'
        final data = jsonBody is Map<String, dynamic>
            ? (jsonBody['data'] ?? jsonBody)
            : jsonBody;

        if (data == null) {
          print('Data is null after unwrapping');
          return null;
        }

        return ChiTietLop.fromJson(data);
      }
      return null;
    } catch (e) {
      print("Error getChiTietLop: $e");
      return null;
    }
  }

  // 💾 Lưu nhận xét và điểm
  static Future<bool> luuNhanXet({
    required String idHocVien,
    required int maLop,
    required int diem,
    required String nhanXet,
  }) async {
    final url = Uri.parse(
      "${AuthService.baseUrl}api/TeacherHomeApi/LuuNhanXet",
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'IDHocVien': idHocVien,
          'MaLop': maLop,
          'Diem': diem,
          'NhanXet': nhanXet,
        }),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return jsonBody['success'] ?? false;
      }
      return false;
    } catch (e) {
      print("Error luuNhanXet: $e");
      return false;
    }
  }
}
