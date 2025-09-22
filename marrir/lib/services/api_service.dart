import 'package:dio/dio.dart';
import 'package:marrir/Dio/dio.dart';

class ApiService {
  static final DioClient _client = DioClient();
  static Dio get _dio => _client.dio;

  // ===== Register User =====
  static Future<Map<String, dynamic>> registerUser(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post("/user/", data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception("Failed to register: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Login User =====
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        "/user/login",
        data: {"email": email, "password": password},
      );

      final res = response.data;
      if (res["error"] == false || res["data"] != null) {
        return Map<String, dynamic>.from(res["data"]);
      } else {
        throw Exception(res["message"] ?? "Login failed");
      }
    } on DioException catch (e) {
      throw Exception("Login error: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Google Login =====
  static Future<Map<String, dynamic>> loginWithGoogle(String authCode) async {
    try {
      final response = await _dio.post(
        "/user/google",
        data: {"code": authCode},
      );

      final res = response.data;
      if (res["error"] == false && res["data"] != null) {
        return Map<String, dynamic>.from(res["data"]);
      } else {
        throw Exception(res["message"] ?? "Google login failed");
      }
    } on DioException catch (e) {
      throw Exception("Google login error: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Facebook Login =====
  static Future<Map<String, dynamic>> loginWithFacebook(
      String accessToken) async {
    try {
      final response = await _dio.post(
        "/user/facebook",
        data: {"accessToken": accessToken},
      );

      final res = response.data;
      if (res["error"] == false && res["data"] != null) {
        return Map<String, dynamic>.from(res["data"]);
      } else {
        throw Exception(res["message"] ?? "Facebook login failed");
      }
    } on DioException catch (e) {
      throw Exception("Facebook login error: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Get User Info =====
  static Future<Map<String, dynamic>> getUserInfo({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        "/user/single",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
        data: {"id": userId},
      );

      final res = response.data;
      if (res["error"] == false && res["data"] != null) {
        return Map<String, dynamic>.from(res["data"]);
      } else {
        throw Exception(res["message"] ?? "Failed to get user information");
      }
    } on DioException catch (e) {
      throw Exception("User info error: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Request Password Reset =====
  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response =
          await _dio.post("/user/request-reset", data: {"email": email});
      return response.data;
    } on DioException catch (e) {
      throw Exception("Reset request error: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Resend OTP =====
  static Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final response =
          await _dio.post("/user/resend-otp", data: {"email": email});
      return response.data;
    } on DioException catch (e) {
      throw Exception("Resend OTP error: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Verify OTP =====
  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    try {
      final response = await _dio
          .post("/user/verify-otp", data: {"email": email, "otp": otp});
      return response.data;
    } on DioException catch (e) {
      throw Exception("Verify OTP error: ${e.response?.data ?? e.message}");
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
      await _dio.post("/user/reset-password", data: {
        "email": email,
        "otp": otp,
        "new_password": password,
        "confirm_password": confirmPassword,
      });
    } on DioException catch (e) {
      throw Exception("Reset password error: ${e.response?.data ?? e.message}");
    }
  }
}
