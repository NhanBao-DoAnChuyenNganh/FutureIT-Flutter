import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class AiChatService {
  Future<String> askAi(String question) async {
    try {
      final url = Uri.parse('${AuthService.baseUrl}api/AiChatApi/ask-ai');

      print('🔵 DEBUG - Calling URL: $url');
      print('🔵 DEBUG - Question: $question');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(question),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      print('🔵 DEBUG - Response Status: ${response.statusCode}');
      print('🔵 DEBUG - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? 'Không thể nhận được phản hồi từ AI';
      } else {
        return 'Lỗi: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      print('🔴 ERROR: $e');
      return 'Lỗi kết nối: $e';
    }
  }
}
