// services/Employee/job_application_service.dart
// import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:marrir/services/storage_service.dart';

class JobApplicationService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();

  JobApplicationService() {
    _dio.options.baseUrl = 'http://10.0.2.2:8000/api/v1';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add interceptors for auth and error handling
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token to all requests
        final token = await _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Content-Type'] = 'application/json';
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        print('Dio Error: ${e.message}');
        return handler.next(e);
      },
    ));
  }

  // Apply for a job
  Future<Map<String, dynamic>> applyForJob({
    required int jobId,
    required String userId,
  }) async {
    try {
      final response = await _dio.post(
        '/job/apply',
        data: {
          'job_id': jobId,
          'user_id': [userId],
          'status': 'pending',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Application submitted successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to apply for job',
          'error': true,
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error: $e',
        'error': true,
      };
    }
  }

  // Remove job application
  Future<Map<String, dynamic>> removeApplication({
    required int jobId,
    required String userId,
  }) async {
    try {
      final response = await _dio.delete(
        '/job/apply/remove',
        data: {
          'job_id': jobId,
          'user_id': userId,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'Application removed successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to remove application',
          'error': true,
        };
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Unexpected error: $e',
        'error': true,
      };
    }
  }

  // Check if user has already applied for a job
  Future<bool> hasUserApplied({
    required int jobId,
    required String userId,
  }) async {
    try {
      final response = await _dio.get(
        '/job/my-applications/$jobId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> applications = response.data;
        return applications.any((app) => app['user_id'] == userId);
      }
      return false;
    } on DioException catch (e) {
      print('Error checking application status: ${e.message}');
      return false;
    } catch (e) {
      print('Error checking application status: $e');
      return false;
    }
  }

  // Get application status for a specific job
  Future<String?> getApplicationStatus({
    required int jobId,
    required String userId,
  }) async {
    try {
      final response = await _dio.get(
        '/job/my-applications/$jobId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> applications = response.data;
        final userApplication = applications.firstWhere(
          (app) => app['user_id'] == userId,
          orElse: () => null,
        );

        return userApplication?['status'];
      }
      return null;
    } on DioException catch (e) {
      print('Error getting application status: ${e.message}');
      return null;
    } catch (e) {
      print('Error getting application status: $e');
      return null;
    }
  }

  // Get all applications for current user
  Future<List<dynamic>> getMyApplications(int jobId) async {
    try {
      final response = await _dio.get(
        '/job/my-applications/$jobId',
      );

      if (response.statusCode == 200) {
        return response.data ?? [];
      }
      return [];
    } on DioException catch (e) {
      print('Error getting my applications: ${e.message}');
      return [];
    } catch (e) {
      print('Error getting my applications: $e');
      return [];
    }
  }

  // Handle Dio errors
  Map<String, dynamic> _handleDioError(DioException e) {
    String errorMessage = 'Network error occurred';

    if (e.response != null) {
      final responseData = e.response?.data;
      final statusCode = e.response?.statusCode;

      // Handle specific status codes
      switch (statusCode) {
        case 409:
          return {
            'success': false,
            'message': 'You have already applied for this job!',
            'error': true,
          };
        case 400:
          errorMessage = responseData?['message'] ?? 'Bad request';
          break;
        case 401:
          errorMessage = 'Unauthorized. Please login again.';
          break;
        case 403:
          errorMessage = 'Forbidden. You do not have permission.';
          break;
        case 404:
          errorMessage = 'Resource not found.';
          break;
        case 422:
          errorMessage = responseData?['message'] ?? 'Validation error';
          break;
        case 500:
          errorMessage = 'Server error. Please try again later.';
          break;
        default:
          errorMessage = responseData?['message'] ?? 'Unknown error occurred';
      }
    } else {
      // Network or other errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection.';
      } else {
        errorMessage = e.message ?? 'Network error occurred';
      }
    }

    return {
      'success': false,
      'message': errorMessage,
      'error': true,
    };
  }

  // Update base URL if needed
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // Add interceptor for logging (useful for debugging)
  void addLoggingInterceptor() {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }
}
