import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import 'package:marrir/Dio/dio.dart';

class ApiService {
  static final DioClient _client = DioClient();
  static Dio get _dio => _client.dio;

  // ===== Register User =====
  static Future<dynamic> registerUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/user/',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
            "Failed to register: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Registration failed: ${e.response?.data ?? e.message}");
    } catch (e) {
      throw Exception("Unknown error: $e");
    }
  }

  // ===== Login User with Role =====
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/user/login',
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> res = response.data;

        if (res["error"] == false || res["data"] != null) {
          return res["data"];
        } else {
          throw Exception(res["message"] ?? "Login failed");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Login failed: ${e.response?.data ?? e.message}");
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogle(String authCode) async {
    try {
      final response = await _dio.post(
        '/user/google',
        data: {"code": authCode},
      );

      if (response.statusCode == 200) {
        final res = response.data;
        if (res["error"] == false && res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception(res["message"] ?? "Google login failed");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Google login failed: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Login with Facebook =====
  static Future<Map<String, dynamic>> loginWithFacebook(
      String accessToken) async {
    try {
      final response = await _dio.post(
        '/user/facebook',
        data: {"accessToken": accessToken},
      );

      if (response.statusCode == 200) {
        final res = response.data;
        if (res["error"] == false && res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception(res["message"] ?? "Facebook login failed");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Facebook login failed: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Get Agent / User Information =====
  static Future<Map<String, dynamic>> getUserInfo({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        '/user/single',
        data: {"id": userId},
      );

      if (response.statusCode == 200) {
        final res = response.data;
        if (res["error"] == false && res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception(res["message"] ?? "Failed to get user information");
        }
      } else {
        throw Exception(
            "Failed to fetch user info: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Get user info failed: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Request Password Reset (send OTP to email) =====
  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await _dio.post(
        '/user/request-reset',
        data: {"email": email},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            "Failed to request reset: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Password reset request failed: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Resend OTP if needed =====
  static Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final response = await _dio.post(
        '/user/resend-otp',
        data: {"email": email},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            "Failed to resend OTP: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Resend OTP failed: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Verify OTP =====
  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    try {
      final response = await _dio.post(
        '/user/verify-otp',
        data: {"email": email, "otp": otp},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            "Failed to verify OTP: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Verify OTP failed: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Reset Password =====
  static Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/user/reset-password',
        data: {
          "email": email,
          "otp": otp,
          "new_password": password,
          "confirm_password": confirmPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to reset password: ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Reset password failed: ${e.response?.data ?? e.message}");
    }
  }

  static Future<Map<String, dynamic>> getDashboardInfo({
    required String token,
    required String userId,
    String period = "monthly",
  }) async {
    try {
      final response = await _dio.post(
        '/dashboard/',
        data: {"id": userId},
      );

      if (response.statusCode == 200) {
        final res = response.data;
        if (res["error"] == false && res["data"] != null) {
          return Map<String, dynamic>.from(res);
        } else {
          throw Exception(res["message"] ?? "Failed to get dashboard info");
        }
      } else {
        throw Exception(
            "Failed to fetch dashboard info: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Get dashboard info failed: ${e.response?.data ?? e.message}");
    }
  }

  // ===== COMPANY INFO APIS =====

  /// ✅ Create or Update company info with file upload
  static Future<Map<String, dynamic>> createOrUpdateCompanyInfo({
    required String token,
    required Map<String, dynamic> fields,
    File? licenseFile,
    File? logoFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'company_info_data_json': jsonEncode(fields),
      });

      if (licenseFile != null) {
        formData.files.add(MapEntry(
          'company_license',
          await MultipartFile.fromFile(licenseFile.path),
        ));
      }

      if (logoFile != null) {
        formData.files.add(MapEntry(
          'company_logo',
          await MultipartFile.fromFile(logoFile.path),
        ));
      }

      final response = await _dio.post(
        '/company_info/',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
            "Failed to save company info: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Save company info failed: ${e.response?.data ?? e.message}");
    }
  }

  static Future<Map<String, dynamic>> getCompanyInfoProgress({
    required String token,
    required String userId,
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '/company_info/progress',
        data: {
          "user_id": userId,
          "email": email,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            "Failed to get company progress: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Get company progress failed: ${e.response?.data ?? e.message}");
    }
  }

  static Future<Map<String, dynamic>> getCompanyInfo({
    required String token,
    required String companyId,
  }) async {
    try {
      final response = await _dio.post(
        '/company_info/single',
        data: {
          "filters": {"id": companyId}
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            "Failed to get company info: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Get company info failed: ${e.response?.data ?? e.message}");
    }
  }

  static Future<Map<String, dynamic>> assignAgentRecruitment({
    required String token,
    required String companyId,
    required String agentId,
  }) async {
    try {
      final response = await _dio.post(
        '/company_info/assign-agent-recruitment',
        data: {"company_id": companyId, "agent_id": agentId},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            "Failed to assign agent: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Assign agent failed: ${e.response?.data ?? e.message}");
    }
  }

  // Create employee
  static Future<Map<String, dynamic>> createEmployee({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        '/user/employee/create',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
            "Failed to create employee: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Create employee failed: ${e.response?.data ?? e.message}");
    }
  }

  // Submit CV / Create or Update Employee
  static Future<Map<String, dynamic>> submitCv({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        '/user/employee/create',
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
            "Failed to submit CV: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Submit CV failed: ${e.response?.data ?? e.message}");
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
    try {
      final Map<String, dynamic> queryParams = {
        "manager_id": managerId,
        "skip": skip.toString(),
        "limit": limit.toString(),
      };
      if (search != null) queryParams["search"] = search;

      final response = await _dio.post(
        '/user/employees',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final res = response.data;
        if (res["error"] == false && res["data"] != null) {
          return List<Map<String, dynamic>>.from(res["data"]);
        } else {
          return [];
        }
      } else {
        throw Exception(
            "Failed to get employees: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Get employees failed: ${e.response?.data ?? e.message}");
    }
  }

  // Get single employee
  static Future<Map<String, dynamic>> getEmployee({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        '/user/employee',
        data: {"user_id": userId},
      );

      if (response.statusCode == 200) {
        final res = response.data;
        if (res["error"] == false && res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception("Employee not found");
        }
      } else {
        throw Exception(
            "Failed to get employee: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Get employee failed: ${e.response?.data ?? e.message}");
    }
  }

  static Future<void> reserveCv({
    required String token,
    required String reserverId,
    required List<int> cvIds,
    String reason = "Reserved by agent",
  }) async {
    try {
      final response = await _dio.post(
        '/reserve/',
        data: {
          "reserver_id": reserverId,
          "status": "accepted",
          "reason": reason,
          "cv_id": cvIds,
        },
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to reserve: ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Reserve CV failed: ${e.response?.data ?? e.message}");
    }
  }
}
