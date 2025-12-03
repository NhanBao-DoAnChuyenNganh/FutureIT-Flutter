import 'dart:convert';
import 'package:do_an_chuyen_nganh/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/teacher_home_model.dart';
import '../models/chi_tiet_lop_model.dart';
import '../models/diem_danh_model.dart';

class TeacherHomeService {
  // Cache duration: 30 phút
  static const int _cacheDuration = 30 * 60 * 1000;

  // ==================== CACHE HELPERS ====================
  
  static Future<void> _saveCache(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cache_teacher_$key', jsonEncode(data));
    await prefs.setInt('cache_teacher_${key}_time', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<Map<String, dynamic>?> _loadCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cache_teacher_$key');
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  static Future<bool> _isCacheExpired(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('cache_teacher_${key}_time') ?? 0;
    return (DateTime.now().millisecondsSinceEpoch - savedTime) > _cacheDuration;
  }

  // ==================== API METHODS ====================

  // 📚 Lấy danh sách lớp đang dạy
  static Future<TeacherHomeData?> getLopDangDay({DateTime? startDate}) async {
    final cacheKey = 'lop_dang_day_${startDate?.toIso8601String() ?? 'now'}';
    
    // Kiểm tra cache
    final cached = await _loadCache(cacheKey);
    final expired = await _isCacheExpired(cacheKey);
    
    if (cached != null && !expired) {
      print('📦 Load từ cache: $cacheKey');
      return TeacherHomeData.fromJson(cached);
    }

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
        
        // Lưu cache
        await _saveCache(cacheKey, jsonBody);
        print('Đã lưu cache: $cacheKey');
        
        return TeacherHomeData.fromJson(jsonBody);
      }
      return null;
    } catch (e) {
      print("Error getLopDangDay: $e");
      
      // Nếu lỗi, trả về cache cũ (nếu có)
      if (cached != null) {
        print('⚠️ Lỗi API, dùng cache cũ');
        return TeacherHomeData.fromJson(cached);
      }
      return null;
    }
  }

  // 📖 Lấy chi tiết 1 lớp + danh sách học viên
  static Future<ChiTietLop?> getChiTietLop(int maLop) async {
    final cacheKey = 'chi_tiet_lop_$maLop';
    
    // Kiểm tra cache
    final cached = await _loadCache(cacheKey);
    final expired = await _isCacheExpired(cacheKey);
    
    if (cached != null && !expired) {
      print('📦 Load từ cache: $cacheKey');
      final data = cached is Map<String, dynamic>
          ? (cached['data'] ?? cached)
          : cached;
      return ChiTietLop.fromJson(data);
    }

    final url = Uri.parse(
      "${AuthService.baseUrl}api/TeacherHomeApi/GetChiTietLop/$maLop",
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

        // API có thể trả về dữ liệu trực tiếp hoặc wrapped trong 'data'
        final data = jsonBody is Map<String, dynamic>
            ? (jsonBody['data'] ?? jsonBody)
            : jsonBody;

        if (data == null) {
          print('Data is null after unwrapping');
          return null;
        }

        // Lưu cache
        await _saveCache(cacheKey, data);
        print('Đã lưu cache: $cacheKey');

        return ChiTietLop.fromJson(data);
      }
      return null;
    } catch (e) {
      print("Error getChiTietLop: $e");
      
      // Nếu lỗi, trả về cache cũ (nếu có)
      if (cached != null) {
        print('Lỗi API, dùng cache cũ');
        final data = cached is Map<String, dynamic>
            ? (cached['data'] ?? cached)
            : cached;
        return ChiTietLop.fromJson(data);
      }
      return null;
    }
  }

  //  Lưu nhận xét và điểm
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

  // Lấy danh sách điểm danh theo ngày
  static Future<DiemDanhData?> getDiemDanhTheoNgay(
    int maLop,
    DateTime ngay,
  ) async {
    final url = Uri.parse(
      "${AuthService.baseUrl}api/TeacherHomeApi/GetDiemDanhTheoNgay/$maLop?ngay=${ngay.toIso8601String()}",
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
        return DiemDanhData.fromJson(jsonBody);
      }
      return null;
    } catch (e) {
      print("Error getDiemDanhTheoNgay: $e");
      return null;
    }
  }

  // Lưu điểm danh hàng loạt
  static Future<bool> luuDiemDanhHangLoat({
    required int maLop,
    required DateTime ngayDiemDanh,
    required List<Map<String, dynamic>> danhSach,
  }) async {
    final url = Uri.parse(
      "${AuthService.baseUrl}api/TeacherHomeApi/LuuDiemDanhHangLoat",
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
          'MaLop': maLop,
          'NgayDiemDanh': ngayDiemDanh.toIso8601String(),
          'DanhSach': danhSach,
        }),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        return jsonBody['success'] ?? false;
      }
      return false;
    } catch (e) {
      print("Error luuDiemDanhHangLoat: $e");
      return false;
    }
  }
}
