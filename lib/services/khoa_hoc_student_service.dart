import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/khoa_hoc.dart';

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
}
