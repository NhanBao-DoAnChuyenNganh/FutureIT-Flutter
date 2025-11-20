import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/tin_tuc_tuyen_dung.dart';

class TinTucService {
  // ===========================
  // LẤY DANH SÁCH TIN TỨC
  // ===========================
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

  // ===========================
  // CACHE CHI TIẾT TIN TỨC
  // ===========================
  static Future<void> saveChiTietTinCache(int id, TinTucTuyenDung tin) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cache_chi_tiet_tin_$id', jsonEncode(tin.toJson()));
    prefs.setInt('cache_chi_tiet_tin_time_$id',
        DateTime.now().millisecondsSinceEpoch);
  }

  static Future<TinTucTuyenDung?> loadChiTietTinCache(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cache_chi_tiet_tin_$id');

    if (jsonString == null) return null;

    return TinTucTuyenDung.fromJson(jsonDecode(jsonString));
  }

  static Future<bool> isChiTietTinExpired(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final savedTime = prefs.getInt('cache_chi_tiet_tin_time_$id') ?? 0;

    final now = DateTime.now().millisecondsSinceEpoch;

    const cacheLimit = 30 * 60 * 1000; // 30 phút
    return (now - savedTime) > cacheLimit;
  }

  // ===========================
  // LẤY CHI TIẾT TIN TỨC (DÙNG CACHE)
  // ===========================
  static Future<TinTucTuyenDung> getChiTietTin(int id) async {
    // --- Load cache trước ---
    final cache = await loadChiTietTinCache(id);
    final expired = await isChiTietTinExpired(id);

    if (cache != null && !expired) {
      print("Dùng cache chi tiết tin #$id");
      return cache;
    }

    // --- Gọi API ---
    final url =
    Uri.parse('${AuthService.baseUrl}api/StudentHomeApi/GetChiTietTin/$id');

    print('🔹 Calling API: $url');

    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
      });

      print('🔹 Status code: ${response.statusCode}');
      print('🔹 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tin = TinTucTuyenDung.fromJson(data);

        // Lưu cache
        await saveChiTietTinCache(id, tin);

        return tin;
      } else {
        if (cache != null) return cache; // API lỗi → fallback cache
        throw Exception('Failed to load chi tiết tin');
      }
    } catch (e) {
      print("API lỗi: $e");
      if (cache != null) return cache; // Offline → fallback cache
      rethrow;
    }
  }
}
