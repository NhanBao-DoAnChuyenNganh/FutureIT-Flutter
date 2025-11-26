import 'dart:convert';
import 'package:do_an_chuyen_nganh/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/student_home_data.dart';

class StudentHomeService {
  Future<StudentHomeData?> getHomeData() async {
    final url = Uri.parse("${AuthService.baseUrl}api/StudentHomeApi/GetStudentHomeData");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final data = StudentHomeData.fromJson(jsonBody['data']);
        return data;
      }
      return null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
