// services/employee_status_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/Dio/dio.dart';

class EmployeeStatusService {
  static final Dio _dio = DioClient().dio;

  // Get headers with token
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) throw Exception("User not authenticated");
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Add employee status
  static Future<Map<String, dynamic>> addStatus({
    required String userId,
    required String status,
    String? reason,
  }) async {
    final headers = await _getHeaders();
    final response = await _dio.post(
      '/employee_status/',
      options: Options(headers: headers),
      data: {
        'user_id': userId,
        'status': status,
        'reason': reason,
      },
    );
    return response.data;
  }

  // Get employee statuses
  static Future<List<Map<String, dynamic>>> getStatuses({
    String? userId,
    int? id,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final headers = await _getHeaders();
    final response = await _dio.post(
      '/employee_status/updates',
      options: Options(headers: headers),
      data: {
        if (userId != null) 'user_id': userId,
        if (id != null) 'id': id,
      },
    );

    return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
  }

  // Update employee status
  static Future<Map<String, dynamic>> updateStatus({
    required int id,
    String? status,
    String? reason,
  }) async {
    final headers = await _getHeaders();
    final response = await _dio.put(
      '/employee_status/',
      options: Options(headers: headers),
      data: {
        'filter': {'id': id},
        'update': {
          if (status != null) 'status': status,
          if (reason != null) 'reason': reason,
        }
      },
    );
    return response.data;
  }

  // Delete employee status
  static Future<Map<String, dynamic>> deleteStatus({
    required int id,
  }) async {
    final headers = await _getHeaders();
    final response = await _dio.delete(
      '/employee_status/',
      options: Options(headers: headers),
      data: {'id': id},
    );
    return response.data;
  }

  // Generate PDF report
  static Future<String> generatePdf({
    required String userId,
  }) async {
    final headers = await _getHeaders();
    final response = await _dio.post(
      '/employee_status/generate-pdf',
      options: Options(headers: headers),
      data: {'user_id': userId},
    );

    return response.data['data'] ?? '';
  }
}
