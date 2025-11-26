import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/khoa_hoc_da_dang_ky_response.dart';

class KhoaHocDaDangKyService {
  static Future<KhoaHocDaDangKyResponse> getKhoaHocDaDangKy({DateTime? startDate}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print('🔹 Token: $token'); // Debug token
    if (token.isEmpty) {
      throw Exception('Chưa đăng nhập');
    }

    String url = '${AuthService.baseUrl}api/StudentHomeApi/GetKhoaHocDaDangKy';
    if (startDate != null) {
      url += '?startDate=${startDate.toIso8601String()}';
    }
    print('🔹 URL: $url'); // Debug URL

    DateTime getStartOfWeek(DateTime date) {
      // Tuần bắt đầu từ thứ 2
      int offset = date.weekday == DateTime.sunday ? -6 : 1 - date.weekday;
      return date.add(Duration(days: offset));
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print('🔹 Response status: ${response.statusCode}'); // Debug status
    print('🔹 Response body: ${response.body}'); // Debug body

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return KhoaHocDaDangKyResponse.fromJson(data);
    } else {
      throw Exception('Failed to load KhoaHocDaDangKy');
    }
  }
}
