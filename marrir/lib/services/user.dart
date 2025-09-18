import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:marrir/Dio/dio.dart';

class ApiService {
  static final Dio _dio = DioClient().dio;

  // ===== Register User =====
  static Future<dynamic> registerUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        "/user/",
        data: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
            "Failed to register: ${response.statusCode} ${response.data}");
      }
    } on DioException catch (e) {
      throw Exception("Register failed: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Login User with Role =====
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        "/user/login",
        data: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final res = response.data;

        if (res["error"] == false || res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
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

  // ===== Example: Get User Info with Token =====
  // static Future<Map<String, dynamic>> getUserInfo(String token) async {
  //   try {
  //     final response = await _dio.get(
  //       "/user/me",
  //       options: Options(
  //         headers: {"Authorization": "Bearer $token"},
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       return Map<String, dynamic>.from(response.data);
  //     } else {
  //       throw Exception(
  //           "Failed to fetch user info: ${response.statusCode} ${response.data}");
  //     }
  //   } on DioException catch (e) {
  //     throw Exception("Get user info failed: ${e.response?.data ?? e.message}");
  //   }
  // }

  // ===== Get User by Email or ID =====
  // ===== Get User Information =====
  static Future<Map<String, dynamic>> getUserInfo({
    String? id,
    String? email,
    String? phoneNumber,
    required String Token,
  }) async {
    try {
      // Build filter object
      final Map<String, dynamic> filters = {};
      if (id != null) filters['id'] = id;
      if (email != null) filters['email'] = email;
      if (phoneNumber != null) filters['phone_number'] = phoneNumber;

      final response = await _dio.post(
        "/user/single",
        data: jsonEncode(filters),
        options: Options(
          headers: {
            "Authorization": "Bearer $Token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final res = response.data;

        if (res["error"] == false && res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception(res["message"] ?? "Failed to get user information");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Get user info failed: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Get Current User Info (convenience method) =====
  static Future<Map<String, dynamic>> getCurrentUserInfo(
      String accessToken) async {
    try {
      // You might want to store the current user ID somewhere after login
      // For now, this will require the client to know their own ID
      final response = await _dio.post(
        "/user/single",
        data: jsonEncode({}), // Empty filter to get current user from token
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final res = response.data;

        if (res["error"] == false && res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception(
              res["message"] ?? "Failed to get current user information");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Get current user info failed: ${e.response?.data ?? e.message}");
    }
  }

  // ===== Get Multiple Users =====
  static Future<List<dynamic>> getUsers({
    required String accessToken,
    int skip = 0,
    int limit = 10,
    String? search,
    String? startDate,
    String? endDate,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'skip': skip,
        'limit': limit,
      };

      if (search != null) queryParams['search'] = search;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.post(
        "/user/paginated",
        data: jsonEncode(filters ?? {}),
        queryParameters: queryParams,
        options: Options(
          headers: {
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final res = response.data;

        if (res["error"] == false && res["data"] != null) {
          return List<dynamic>.from(res["data"]);
        } else {
          throw Exception(res["message"] ?? "Failed to get users");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Get users failed: ${e.response?.data ?? e.message}");
    }
  }
}
