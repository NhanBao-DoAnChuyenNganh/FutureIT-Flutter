import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  /// ✅ Lấy baseUrl từ .env
  static String get baseUrl {
    final domain = dotenv.env['API_BASE_URL'] ?? "http://localhost:5215/";
    return domain.endsWith('/') ? domain : '$domain/';
  }

  /// 🟢 Đăng nhập
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${baseUrl}api/accountapi/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 10));

      print('LOGIN RESPONSE: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔹 Kiểm tra isApproved
        final bool isApproved = data['isApproved'] ?? true;
        final List roles = data['roles'] ?? [];
        final bool restrictedRole = roles.any((r) => r == "Admin" || r == "Teacher" || r == "Staff");

        if (!isApproved && restrictedRole) {
          return {"error": "Tài khoản chưa được duyệt"};
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('email', data['email'] ?? '');
        await prefs.setString('username', data['username'] ?? '');
        await prefs.setString('sdt', data['sdt'] ?? '');
        await prefs.setString('diaChi', data['diaChi'] ?? '');
        await prefs.setString('ngayDK', data['ngayDK'] ?? '');
        await prefs.setString('avatarBase64', data['avatarBase64'] ?? '');

        final role = roles.isNotEmpty ? roles[0] : 'Unknown';
        await prefs.setString('role', role);

        return data;
      } else {
        String message = "Sai tài khoản hoặc mật khẩu";
        try {
          final r = jsonDecode(response.body);
          if (r is Map && r.containsKey('message')) message = r['message'];
        } catch (_) {}
        return {"error": message};
      }
    } catch (e) {
      print('LOGIN ERROR: $e');
      return {"error": "Không thể kết nối tới server: $e"};
    }
  }


  /// 🟢 Đăng ký
  static Future<Map<String, dynamic>> register({
    required String hoTen,
    required String sdt,
    required String diaChi,
    required String email,
    required String password,
    required String role,
    required String avatarPath,
  }) async {
    final url = Uri.parse('${baseUrl}api/accountapi/register');
    var request = http.MultipartRequest('POST', url);

    request.fields['HoTen'] = hoTen;
    request.fields['SDT'] = sdt;
    request.fields['DiaChi'] = diaChi;
    request.fields['Email'] = email;
    request.fields['Password'] = password;
    request.fields['Role'] = role;

    if (avatarPath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('Avatar', avatarPath));
    }

    try {
      final response = await request.send().timeout(const Duration(seconds: 15));
      final responseBody = await response.stream.bytesToString();

      print('REGISTER RESPONSE: ${response.statusCode} $responseBody');

      if (response.statusCode == 200) {
        return jsonDecode(responseBody);
      } else {
        String message = "Đăng ký thất bại";
        try {
          final r = jsonDecode(responseBody);
          if (r is Map && r.containsKey('message')) message = r['message'];
        } catch (_) {}
        return {"error": message};
      }
    } catch (e) {
      print('REGISTER ERROR: $e');
      return {"error": "Không thể kết nối tới server: $e"};
    }
  }

  /// 🔴 Cập nhật hồ sơ
  static Future<Map<String, dynamic>> updateProfile({
    required String email,
    required String hoTen,
    required String sdt,
    required String diaChi,
    File? avatar,
  }) async {
    final url = Uri.parse('${baseUrl}api/accountapi/updateprofile');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    print('UPDATE DATA: Email=$email, HoTen=$hoTen, SDT=$sdt, DiaChi=$diaChi');

    var request = http.MultipartRequest('POST', url);

    // 🧩 Thêm token vào header
    if (token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['Email'] = email;
    request.fields['HoTen'] = hoTen;
    request.fields['SDT'] = sdt;
    request.fields['DiaChi'] = diaChi;

    if (avatar != null) {
      request.files.add(await http.MultipartFile.fromPath('Avatar', avatar.path));
    }

    try {
      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      print('UPDATE RESPONSE: ${response.statusCode} $respStr');

      if (response.statusCode == 200) {
        return jsonDecode(respStr);
      } else {
        return {'error': jsonDecode(respStr)['message'] ?? 'Cập nhật thất bại'};
      }
    } catch (e) {
      return {'error': 'Không thể kết nối tới server: $e'};
    }
  }

  /// 🚪 Đăng xuất
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// 🔹 Kiểm tra đăng nhập
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  /// 🔹 Lấy role hiện tại
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  /// 🔹 Lấy username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  /// 🔹 Lấy email
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  /// 🔹 Lấy avatar base64
  static Future<String?> getAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('avatarBase64');
  }
}
