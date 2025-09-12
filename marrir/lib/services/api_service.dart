import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // TODO: replace with your backend API base URL
  static const String baseUrl = "http://10.0.2.2:8000";
  // Android emulator: use 10.0.2.2
  // Real device on same WiFi: http://<your_pc_ip>:8000

  // ===== Register User =====
  static Future<dynamic> registerUser(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/api/v1/user/"); // check your backend route
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to register: ${response.statusCode} ${response.body}");
    }
  }

  // ===== Login User with Role =====
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
   
  }) async {
    final url =
        Uri.parse("$baseUrl/api/v1/user/login"); // backend route
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> res = jsonDecode(response.body);

      if (res["error"] == false || res["data"] != null) {
        // Return only user data
        return res["data"];
      } else {
        throw Exception(res["message"] ?? "Login failed");
      }
    } else {
      throw Exception("Server Error: ${response.statusCode}");
    }
  }

  // ===== Example: Get User Info with Token =====
  static Future<Map<String, dynamic>> getUserInfo(String token) async {
    final url = Uri.parse("$baseUrl/api/v1/user/me/"); // your route
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to fetch user info: ${response.statusCode} ${response.body}");
    }
  }
}
