import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marrir/Dio/dio.dart';

class EmployeeDashboardService {
  static final Dio _dio = DioClient().dio;

  // Get CV progress
  static Future<Map<String, dynamic>> getCVProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final userId = prefs.getString('user_id');

    if (token == null || userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _dio.post(
        '/cv/progress',
        data: {'user_id': userId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Handle different response structures from backend
      if (response.statusCode == 200) {
        final responseData = response.data;

        // Case 1: Direct progress data in response
        if (responseData is Map<String, dynamic> &&
            _isProgressData(responseData)) {
          return responseData;
        }

        // Case 2: Progress data nested under 'data' key
        else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          return responseData['data'];
        }

        // Case 3: Error response from backend
        else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('error') &&
            responseData['error'] == true) {
          throw Exception(
              responseData['message'] ?? 'Error loading CV progress');
        }

        // Case 4: Unexpected response format
        else {
          throw Exception('Invalid response format from server');
        }
      } else if (response.statusCode == 404) {
        throw Exception('CV not found for this user');
      } else if (response.statusCode == 400) {
        throw Exception('User ID is required');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle backend error responses
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        }
        throw Exception('Server error: ${e.response?.statusCode}');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout');
      } else if (e.type == DioExceptionType.sendTimeout) {
        throw Exception('Send timeout');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to load CV progress: $e');
    }
  }

  // Get Process progress
  static Future<Map<String, dynamic>> getProcessProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final userId = prefs.getString('user_id');

    if (token == null || userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _dio.post(
        '/process/progress',
        data: {'user_id': userId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Handle different response structures from backend
      if (response.statusCode == 200) {
        final responseData = response.data;

        // Case 1: Direct progress data in response
        if (responseData is Map<String, dynamic> &&
            _isProcessProgressData(responseData)) {
          return responseData;
        }

        // Case 2: Progress data nested under 'data' key
        else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          return responseData['data'];
        }

        // Case 3: Error response from backend
        else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('error') &&
            responseData['error'] == true) {
          throw Exception(
              responseData['message'] ?? 'Error loading process progress');
        }

        // Case 4: Unexpected response format
        else {
          throw Exception('Invalid response format from server');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Process not found for this user');
      } else if (response.statusCode == 400) {
        throw Exception('User ID is required');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle backend error responses
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        }
        throw Exception('Server error: ${e.response?.statusCode}');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to load process progress: $e');
    }
  }

  // Get all dashboard data with better error handling
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final cvResult = await getCVProgress().catchError((e) {
        // Return an empty map for CV progress and store the error
        return <String, dynamic>{'__error__': e.toString()};
      });

      final processResult = await getProcessProgress().catchError((e) {
        // Return an empty map for process progress and store the error
        return <String, dynamic>{'__error__': e.toString()};
      });

      // Extract errors from the results
      final cvError =
          cvResult.containsKey('__error__') ? cvResult['__error__'] : null;
      final processError = processResult.containsKey('__error__')
          ? processResult['__error__']
          : null;

      // Remove error keys from the results
      final cvProgress = Map<String, dynamic>.from(cvResult)
        ..remove('__error__');
      final processProgress = Map<String, dynamic>.from(processResult)
        ..remove('__error__');

      // Build errors map
      final errors = <String, dynamic>{};
      if (cvError != null) errors['cv_error'] = cvError;
      if (processError != null) errors['process_error'] = processError;

      return {
        'cv_progress': cvProgress,
        'process_progress': processProgress,
        'errors': errors,
      };
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }

  // Helper method to check if response contains CV progress data
  static bool _isProgressData(Map<String, dynamic> data) {
    final progressFields = [
      'id_progress',
      'personal_info_progress',
      'address_progress',
      'education_progress',
      'photo_and_language_progress',
      'experience_progress',
      'reference_progress',
      'contact_progress'
    ];

    return progressFields.any(data.containsKey);
  }

  // Helper method to check if response contains process progress data
  static bool _isProcessProgressData(Map<String, dynamic> data) {
    final processFields = [
      'acceptance_of_application_progress',
      'signing_of_contract_progress',
      'passport_progress',
      'insurance_progress',
      'medical_report_progress',
      'certificate_of_freedom_progress',
      'coc_progress',
      'enjaz_slip_to_agents_progress',
      'enjaz_slip_for_recruitment_progress',
      'worker_file_to_embassy_progress',
      'visa_progress',
      'worker_file_in_labor_office_progress',
      'receive_travel_authorization_code_progress',
      'molsa_letter_progress',
      'ticket_progress',
      'arrive_progress'
    ];

    return processFields.any(data.containsKey);
  }

  // Submit ratings
  static Future<Map<String, dynamic>> submitRatings(
      Map<String, dynamic> ratingData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final userId = prefs.getString('user_id');

    if (token == null || userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // CORRECT data structure that matches RatingCreateSchema
      // Don't include 'type' field - let backend set it automatically
      final correctRatingData = {
        "user_id": userId,
        "value": ratingData['value'], // This MUST be a float value
        "description": ratingData['description'] ?? "", // Required field
        "rated_by": userId, // The person giving the rating
        // REMOVE 'type' field - backend will set it based on user role
      };

      // Validate that value is provided and is a number
      if (correctRatingData['value'] == null) {
        throw Exception('Rating value is required');
      }

      final response = await _dio.post(
        '/rating/',
        data: correctRatingData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to submit ratings: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to submit ratings: $e');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get user's promotion subscription
  Future<Map<String, dynamic>?> getUserSubscription() async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.get(
        '/promotion/packages/subscriptions',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Check if the response indicates no active subscriptions
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message') &&
            responseData['message'] == 'No active subscriptions') {
          return null;
        }

        return responseData;
      } else {
        throw Exception('Failed to load subscription: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Handle 404 or other errors gracefully
        if (e.response?.statusCode == 404) {
          return null; // No subscription found
        }
        throw Exception(
            'Failed to load subscription: ${e.response?.statusCode}');
      } else {
        throw Exception('Failed to load subscription: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to load subscription: $e');
    }
  }

  // Buy a promotion package
  Future<Map<String, dynamic>> buyPromotionPackage(int packageId) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.post(
        '/promotion/packages',
        data: {'id': packageId},
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to buy package: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'Failed to buy package: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Failed to buy package: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to buy package: $e');
    }
  }

  // Update the _getHeaders method to be static
  Future<Map<String, String>> _getHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all promotion packages using Dio
  Future<List<Map<String, dynamic>>> getPromotionPackages() async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.get(
        '/promotion/packages',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(
            'Failed to load promotion packages: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'Failed to load promotion packages: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Failed to load promotion packages: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to load promotion packages: $e');
    }
  }
}
