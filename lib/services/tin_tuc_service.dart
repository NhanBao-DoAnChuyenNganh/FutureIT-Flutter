import 'dart:convert';
import 'package:do_an_chuyen_nganh/models/tin_tuc_tuyen_dung.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/tin_tuc_tuyen_dung.dart';

class TinTucService {
  static Future<List<TinTucTuyenDung>> getAllTinTuc() async {
    final url = Uri.parse('${AuthService.baseUrl}api/StudentHomeApi/GetTinTuc');

    print('🔹 Calling API: $url');

    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
    });

    print('🔹 Status code: ${response.statusCode}');
    print('🔹 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      print('🔹 Received ${data.length} items');
      return data.map((e) => TinTucTuyenDung.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load TinTuc');
    }
  }

  static Future<TinTucTuyenDung> getChiTietTin(int id) async {
    final url = Uri.parse('${AuthService.baseUrl}api/StudentHomeApi/GetChiTietTin/$id');

    print('🔹 Calling API: $url');

    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
    });

    print('🔹 Status code: ${response.statusCode}');
    print('🔹 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return TinTucTuyenDung.fromJson(data);
    } else {
      throw Exception('Failed to load chi tiết tin');
    }
  }
}
