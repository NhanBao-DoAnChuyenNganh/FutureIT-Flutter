import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/khoa_hoc.dart';
import '../models/chi_tiet_khoa_hoc.dart';
class KhoaHocService {
  static Future<List<KhoaHoc>> getAllKhoaHoc() async {
    final url = Uri.parse('${AuthService.baseUrl}api/StudentHomeApi/GetKhoaHoc');

    print('🔹 Calling API: $url'); // Debug URL

    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
      // Nếu có token:
      // "Authorization": "Bearer ${await AuthService.getToken()}",
    });

    print('🔹 Status code: ${response.statusCode}'); // Debug status code
    print('🔹 Response body: ${response.body}'); // Debug body

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      print('🔹 Received ${data.length} items \n'); // Debug số item
      return data.map((e) => KhoaHoc.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load KhoaHoc');
    }
  }
  static Future<List<KhoaHoc>> searchOrFilter({String? ten, String? tenLoai}) async {
    // Debug giá trị input
    print('🔹 SearchOrFilter called with ten="$ten", tenLoai="$tenLoai"');

    final url = Uri.parse(
        '${AuthService.baseUrl}api/StudentHomeApi/SearchOrFilter?ten=${Uri.encodeQueryComponent(ten ?? "")}&tenLoai=${Uri.encodeQueryComponent(tenLoai ?? "")}'
    );


    print('🔹 API URL: $url');

    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
    });
    print("Debug cho tìm kiếm!!!!!!!!!!!");
    print('🔹 Status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      print('🔹 Received ${data.length} items:');
      for (var item in data) {
        print('   - ${item['tenKhoaHoc']}');
      }
      return data.map((e) => KhoaHoc.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load KhoaHoc');
    }
  }


  static Future<List<KhoaHoc>> filterByPrice(int luaChon) async {
    final url = Uri.parse('${AuthService.baseUrl}api/StudentHomeApi/LocTheoGia?luaChon=$luaChon');
    return _fetchKhoaHoc(url);
  }

  static Future<List<KhoaHoc>> _fetchKhoaHoc(Uri url) async {
    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => KhoaHoc.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load KhoaHoc');
    }
  }
  /// GET chi tiết khóa học
  static Future<ChiTietKhoaHoc> getChiTietKhoaHoc(int maKhoaHoc) async {
    final url = Uri.parse('${AuthService.baseUrl}api/StudentHomeApi/GetChiTietKhoaHoc/$maKhoaHoc');
    print('🔹 GET ChiTietKhoaHoc URL: $url');

    final response = await http.get(url, headers: {"Content-Type": "application/json"});
    print('🔹 Status code: ${response.statusCode}');
    print('🔹 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ChiTietKhoaHoc.fromJson(data);
    } else {
      throw Exception('Failed to load ChiTietKhoaHoc');
    }
  }

// POST gửi đánh giá
  static Future<bool> guiDanhGia({
    required int maKhoaHoc,
    required int soSao,
    required String noiDung,
  }) async {
    final url = Uri.parse('${AuthService.baseUrl}api/StudentHomeApi/GuiDanhGia');

    // Lấy token từ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    print('🔹 POST GuiDanhGia URL: $url');
    print('🔹 Payload: ${jsonEncode({"MaKhoaHoc": maKhoaHoc, "SoSao": soSao, "NoiDung": noiDung})}');
    print('🔹 Token: $token');

    if (token.isEmpty) {
      print('⚠️ Token trống, vui lòng đăng nhập trước');
      return false;
    }

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        if (token.isNotEmpty) "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "maKhoaHoc": maKhoaHoc,
        "soSao": soSao,
        "noiDung": noiDung,
      }),
    );


    print('🔹 Status code: ${response.statusCode}');
    print('🔹 Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('✅ Gửi đánh giá thành công');
      return true;
    } else if (response.statusCode == 401 || response.statusCode == 302) {
      print('❌ Lỗi xác thực, có thể token hết hạn hoặc chưa đăng nhập');
      return false;
    } else {
      print('❌ Lỗi khác khi gửi đánh giá');
      return false;
    }
  }



// POST toggle yêu thích
  static Future<bool> toggleYeuThich(int maKhoaHoc) async {
    final url = Uri.parse('${AuthService.baseUrl}api/StudentHomeApi/ToggleQuanTam');
    print('🔹 POST ToggleQuanTam URL: $url');
    print('🔹 Payload: $maKhoaHoc');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(maKhoaHoc),
    );

    print('🔹 Status code: ${response.statusCode}');
    print('🔹 Response body: ${response.body}');

    return response.statusCode == 200;
  }

// GET danh sách quan tâm
  static Future<List<KhoaHoc>> getDanhSachQuanTam() async {
    final url = Uri.parse('${AuthService.baseUrl}api/StudentHomeApi/GetDanhSachQuanTam');
    print('🔹 GET GetDanhSachQuanTam URL: $url');

    final response = await http.get(url, headers: {"Content-Type": "application/json"});
    print('🔹 Status code: ${response.statusCode}');
    print('🔹 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      print('🔹 Received ${data.length} items');
      return data.map((e) => KhoaHoc.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load danh sách quan tâm');
    }
  }


}
