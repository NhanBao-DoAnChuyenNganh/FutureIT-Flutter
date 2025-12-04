import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiChatService {
  /// 💬 Gửi câu hỏi tới AI và lưu lịch sử (nếu đã đăng nhập)
  Future<String> askAi(String question) async {
    try {
      final url = Uri.parse('${AuthService.baseUrl}api/AiChatApi/ask-ai');

      print('DEBUG - Gọi URL: $url');
      print('DEBUG - Câu hỏi: $question');

      // Lấy token từ SharedPreferences
      final isLogged = await AuthService.isLoggedIn();
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Nếu đã đăng nhập, thêm token vào header
      if (isLogged) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';
        if (token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          print('DEBUG - Token được thêm vào request');
        }
      } else {
        print('CẢNH BÁO - Chưa đăng nhập, hội thoại sẽ không được lưu');
      }

      final response = await http
          .post(url, headers: headers, body: jsonEncode(question))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Hết thời gian chờ'),
          );

      print('DEBUG - Trạng thái phản hồi: ${response.statusCode}');
      print('DEBUG - Nội dung phản hồi: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? 'Không thể nhận được phản hồi từ AI';
      } else {
        return 'Lỗi: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      print('LỖI: $e');
      return 'Lỗi kết nối: $e';
    }
  }

  /// 📜 Lấy lịch sử hội thoại (chỉ khi đã đăng nhập)
  Future<List<Map<String, dynamic>>> getChatHistory() async {
    try {
      final isLogged = await AuthService.isLoggedIn();

      // Nếu chưa đăng nhập, return list rỗng
      if (!isLogged) {
        print('CẢNH BÁO - Chưa đăng nhập, không thể lấy lịch sử');
        return [];
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        print('CẢNH BÁO - Token không tìm thấy');
        return [];
      }

      final url = Uri.parse('${AuthService.baseUrl}api/AiChatApi/history');

      print('DEBUG - Đang lấy lịch sử từ: $url');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Hết thời gian chờ'),
          );

      print('DEBUG - Trạng thái lịch sử: ${response.statusCode}');
      print('DEBUG - Nội dung lịch sử: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Lấy lịch sử thành công: ${data.length} tin nhắn');
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        print('LỖI - Token hết hạn hoặc không hợp lệ');
        return [];
      } else {
        print('LỖI - Không thể lấy lịch sử: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('LỖI: $e');
      return [];
    }
  }
}
