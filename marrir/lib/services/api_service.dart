import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000";
  

  // ===== Register User =====
  static Future<dynamic> registerUser(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/api/v1/user/");
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
    final url = Uri.parse("$baseUrl/api/v1/user/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> res = jsonDecode(response.body);

      if (res["error"] == false || res["data"] != null) {
        return res["data"];
      } else {
        throw Exception(res["message"] ?? "Login failed");
      }
    } else {
      throw Exception("Server Error: ${response.statusCode}");
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogle(String authCode) async {
  final url = Uri.parse("$baseUrl/api/v1/user/google");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"code": authCode}), // send auth code, not ID token
  );

  if (response.statusCode == 200) {
    final res = jsonDecode(response.body);
    if (res["error"] == false && res["data"] != null) {
      return Map<String, dynamic>.from(res["data"]);
    } else {
      throw Exception(res["message"] ?? "Google login failed");
    }
  } else {
    throw Exception("Server Error: ${response.statusCode}");
  }
}


  // ===== Login with Facebook =====
static Future<Map<String, dynamic>> loginWithFacebook(String accessToken) async {
  final url = Uri.parse("$baseUrl/api/v1/user/facebook");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"accessToken": accessToken}), // send accessToken to backend
  );

  if (response.statusCode == 200) {
    final res = jsonDecode(response.body);

    // Same style as Google login: check error false & data exists
    if (res["error"] == false && res["data"] != null) {
      return Map<String, dynamic>.from(res["data"]);
    } else {
      throw Exception(res["message"] ?? "Facebook login failed");
    }
  } else {
    throw Exception("Server Error: ${response.statusCode}");
  }
}

// ===== Get Agent / User Information =====
static Future<Map<String, dynamic>> getUserInfo({
  required String token,
  required String userId,
}) async {
  final url = Uri.parse("$baseUrl/api/v1/user/single");

  final Map<String, dynamic> filters = {
    "id": userId,
  };

  final response = await http.post(
    url,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
    body: jsonEncode(filters),
  );

  if (response.statusCode == 200) {
    final res = jsonDecode(response.body);
    if (res["error"] == false && res["data"] != null) {
      return Map<String, dynamic>.from(res["data"]);
    } else {
      throw Exception(res["message"] ?? "Failed to get user information");
    }
  } else {
    throw Exception(
        "Failed to fetch user info: ${response.statusCode} ${response.body}");
  }
}

// ===== Request Password Reset (send OTP to email) =====
static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
  final url = Uri.parse("$baseUrl/api/v1/user/request-reset");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to request reset: ${response.statusCode} ${response.body}");
  }
}

// ===== Resend OTP if needed =====
static Future<Map<String, dynamic>> resendOtp(String email) async {
  final url = Uri.parse("$baseUrl/api/v1/user/resend-otp");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to resend OTP: ${response.statusCode} ${response.body}");
  }
}

// ===== Verify OTP =====
static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
  final url = Uri.parse("$baseUrl/api/v1/user/verify-otp");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email, "otp": otp}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Failed to verify OTP: ${response.statusCode} ${response.body}");
  }
}

// ===== Reset Password =====
static Future<void> resetPassword({
  required String email,
  required String otp,
  required String password,
  required String confirmPassword,
}) async {
  final url = Uri.parse("$baseUrl/api/v1/user/reset-password");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "otp": otp,
      "new_password": password,
      "confirm_password": confirmPassword, // ✅ Add this
    }),
  );

  if (response.statusCode == 200) {
    return;
  } else {
    throw Exception("Failed to reset password: ${response.body}");
  }
}



}