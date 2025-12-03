import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ThanhToanService {
  static String get baseUrl {
    final domain = dotenv.env['API_BASE_URL'] ?? "http://localhost:5215/";
    return domain.endsWith('/') ? domain : '$domain/';
  }

  /// Thanh toán Momo
  static Future<Map<String, dynamic>> createPaymentMomo({
    required int maKhoaHoc,
    required double hocPhi,
    required String tenKhoaHoc,
    required String ngayHoc,
  }) async {
    final url = Uri.parse('${baseUrl}api/PaymentApi/CreatePaymentMomo');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final orderId = const Uuid().v4();

    try {
      // Sử dụng Client để không tự động follow redirect
      final client = http.Client();
      final request = http.Request('POST', url);
      request.headers['Content-Type'] = 'application/json';
      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.body = jsonEncode({
        "Amount": hocPhi.toInt().toString(),
        "OrderId": orderId,
        "OrderInfo": "Thanh toán học phí bằng Momo",
        "FullName": "Thanh toán Momo",
        "ExtraData": maKhoaHoc.toString(),
        "OrderInfomation": "Đăng ký $tenKhoaHoc + $ngayHoc",
      });

      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      client.close();

      print('========== MOMO DEBUG ==========');
      print('URL: $url');
      print('Token: ${token.isNotEmpty ? "Có token" : "Không có token"}');
      print('Status: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
      print('================================');

      // Xử lý redirect 302 - lấy Location header
      if (response.statusCode == 302 || response.statusCode == 301) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null && redirectUrl.isNotEmpty) {
          print('Redirect URL: $redirectUrl');
          return {"success": true, "payUrl": redirectUrl};
        }
        return {"error": "Không nhận được URL thanh toán từ server"};
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('PayUrl: ${data['payUrl']}');
        return data;
      } else if (response.statusCode == 401) {
        return {"error": "Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại."};
      } else if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          return {"error": errorData['message'] ?? "Yêu cầu không hợp lệ"};
        } catch (_) {
          return {"error": "Yêu cầu không hợp lệ"};
        }
      } else if (response.statusCode == 404) {
        return {"error": "Không tìm thấy khóa học"};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {"error": errorData['message'] ?? "Thanh toán thất bại (${response.statusCode})"};
        } catch (_) {
          return {"error": "Thanh toán thất bại: ${response.statusCode}"};
        }
      }
    } catch (e) {
      print('MOMO ERROR: $e');
      return {"error": "Lỗi kết nối: $e"};
    }
  }

  /// Thanh toán ZaloPay
  static Future<Map<String, dynamic>> createPaymentZaloPay({
    required int maKhoaHoc,
    required double hocPhi,
    required String tenKhoaHoc,
    required String ngayHoc,
  }) async {
    final url = Uri.parse('${baseUrl}api/PaymentApi/CreatePaymentZaloPay');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final orderId = const Uuid().v4();

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "Amount": hocPhi.toInt().toString(),
          "OrderId": orderId,
          "OrderInfo": "Thanh toán học phí bằng ZaloPay",
          "FullName": "Thanh toán ZaloPay",
          "ExtraData": maKhoaHoc.toString(),
          "OrderInfomation": "Đăng ký $tenKhoaHoc + $ngayHoc",
        }),
      ).timeout(const Duration(seconds: 15));

      print('ZALOPAY RESPONSE: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Thanh toán thất bại: ${response.statusCode}"};
      }
    } catch (e) {
      print('ZALOPAY ERROR: $e');
      return {"error": "Không thể kết nối tới server: $e"};
    }
  }
}
