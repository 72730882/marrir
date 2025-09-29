import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:marrir/Dio/dio.dart';

class ApiService {
  static final DioClient _client = DioClient();
  static Dio get _dio => _client.dio;
  static const String baseUrl = "https://api.marrir.com"; // for your device
  // static const String baseUrl = "http://127.0.0.1:8000"; // for your device

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
  static Future<Map<String, dynamic>> loginWithFacebook(
      String accessToken) async {
    final url = Uri.parse("$baseUrl/api/v1/user/facebook");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"accessToken": accessToken}), // send accessToken to backend
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
      throw Exception(
          "Failed to request reset: ${response.statusCode} ${response.body}");
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
      throw Exception(
          "Failed to resend OTP: ${response.statusCode} ${response.body}");
    }
  }

// ===== Verify OTP =====
  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    final url = Uri.parse("$baseUrl/api/v1/user/verify-otp");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to verify OTP: ${response.statusCode} ${response.body}");
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

  static Future<Map<String, dynamic>> getDashboardInfo({
    required String token,
    required String userId,
    String period = "monthly",
  }) async {
    final url = Uri.parse("$baseUrl/api/v1/dashboard/");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"id": userId}),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      if (res["error"] == false && res["data"] != null) {
        return Map<String, dynamic>.from(res);
      } else {
        throw Exception(res["message"] ?? "Failed to get dashboard info");
      }
    } else {
      throw Exception(
          "Failed to fetch dashboard info: ${response.statusCode} ${response.body}");
    }
  }

// ===== COMPANY INFO APIS =====

  /// ✅ Create or Update company info with file upload
  static Future<Map<String, dynamic>> createOrUpdateCompanyInfo({
    required String token,
    required Map<String, dynamic>
        fields, // pass all fields like company_name, location, etc
    File? licenseFile,
    File? logoFile,
  }) async {
    final uri = Uri.parse("$baseUrl/api/v1/company_info/");
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    // send all fields as a JSON string
    request.fields['company_info_data_json'] = jsonEncode(fields);

    if (licenseFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('company_license', licenseFile.path),
      );
    }

    if (logoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('company_logo', logoFile.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to save company info: ${response.statusCode} ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> getCompanyInfoProgress({
    required String token,
    required String userId,
    required String email,
  }) async {
    final url = Uri.parse("$baseUrl/api/v1/company_info/progress");
    final body = jsonEncode({
      "user_id": userId,
      "email": email,
    });

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to get company progress: ${response.statusCode} ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> getCompanyInfo({
    required String token,
    required String companyId,
  }) async {
    final url = Uri.parse("$baseUrl/api/v1/company_info/single");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "filters": {"id": companyId}
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to get company info: ${response.statusCode} ${response.body}");
    }
  }

  static Future<Map<String, dynamic>> assignAgentRecruitment({
    required String token,
    required String companyId,
    required String agentId,
  }) async {
    final url =
        Uri.parse("$baseUrl/api/v1/company_info/assign-agent-recruitment");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"company_id": companyId, "agent_id": agentId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to assign agent: ${response.statusCode} ${response.body}");
    }
  }

// Create employee
  static Future<Map<String, dynamic>> createEmployee({
    required String token,
    required Map<String, dynamic> data, // only the employee fields
  }) async {
    final url = Uri.parse("$baseUrl/api/v1/user/employee/create");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data), // send only backend-expected fields
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to create employee: ${response.statusCode} ${response.body}");
    }
  }

// Submit CV / Create or Update Employee
  static Future<Map<String, dynamic>> submitCv({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse("$baseUrl/api/v1/user/employee/create");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to submit CV: ${response.statusCode} ${response.body}");
    }
  }

// List employees under user
  static Future<List<Map<String, dynamic>>> getEmployees({
    required String token,
    required String managerId,
    int skip = 0,
    int limit = 1000,
    String? search,
  }) async {
    final queryParameters = {
      "manager_id": managerId,
      "skip": skip.toString(),
      "limit": limit.toString(),
    };
    if (search != null) queryParameters["search"] = search;

    final url = Uri.parse("$baseUrl/api/v1/user/employees")
        .replace(queryParameters: queryParameters);

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      if (res["error"] == false && res["data"] != null) {
        // Ensure it's a list of maps
        return List<Map<String, dynamic>>.from(res["data"]);
      } else {
        return [];
      }
    } else {
      throw Exception(
          "Failed to get employees: ${response.statusCode} ${response.body}");
    }
  }

// Get single employee
  static Future<Map<String, dynamic>> getEmployee({
    required String token,
    required String userId,
  }) async {
    final url = Uri.parse("$baseUrl/api/v1/user/employee");
    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"user_id": userId}),
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      if (res["error"] == false && res["data"] != null) {
        return Map<String, dynamic>.from(res["data"]);
      } else {
        throw Exception("Employee not found");
      }
    } else {
      throw Exception(
          "Failed to get employee: ${response.statusCode} ${response.body}");
    }
  }

  static Future<void> reserveCv({
    required String token,
    required String reserverId,
    required List<int> cvIds, // 👈 must be integers
    String reason = "Reserved by agent",
  }) async {
    final url = Uri.parse("$baseUrl/api/v1/reserve/");

    final body = {
      "reserver_id": reserverId,
      "status": "accepted",
      "reason": reason,
      "cv_id": cvIds, // ✅ integers, not strings
    };

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to reserve: ${response.body}");
    }
  }
}
