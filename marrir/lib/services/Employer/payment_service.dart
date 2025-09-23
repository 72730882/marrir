import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  final Dio _dio;

  PaymentService()
      : _dio = Dio(
          BaseOptions(
            // baseUrl: "http://127.0.0.1:8000",
            baseUrl: "http://10.242.120.219:8000",
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        print('❌ Dio Error: ${error.message}');
        if (error.response != null) {
          print('📊 Status: ${error.response!.statusCode}');
          print('📝 Data: ${error.response!.data}');
        }
        return handler.next(error);
      },
    ));
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        print('❌ No auth token found in SharedPreferences');
        return null;
      }
      print('✅ Auth token retrieved successfully');
      return token;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  Future<String?> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      return userId;
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  // ================== TELR PAYMENT ENDPOINTS ==================

  // ✅ ENDPOINT 1: Create Telr payment for promotion packages
  Future<Map<String, dynamic>> createTelrPayment({
    required double amount,
    required String package,
    required String userId,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }

      print('💰 Initiating Telr payment:');
      print('📦 Package: $package');
      print('💵 Amount: $amount');
      print('👤 User ID: $userId');

      final response = await _dio.post(
        '/payment/telr/createx', // Your Telr endpoint
        data: {
          'amount': amount,
          'method': true, // Required by your backend
          'package': package,
          'user_id': userId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('✅ Telr payment initiated successfully');
      print('📊 Response: ${response.data}');

      return response.data;
    } on DioException catch (e) {
      print('❌ Telr payment failed: ${e.message}');
      throw Exception('Failed to initiate Telr payment: ${e.message}');
    }
  }

  // ✅ ENDPOINT 2: Create Telr payment for multiple users (if needed)
  Future<Map<String, dynamic>> createTelrPaymentMultiple({
    required double amount,
    required String package,
    required List<String> userIds,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }

      final response = await _dio.post(
        '/payment/telr/multiple/create',
        data: {
          'amount': amount,
          'method': true,
          'package': package,
          'user_ids': userIds,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to initiate multiple Telr payment: ${e.message}');
    }
  }

  // ✅ ENDPOINT 3: Check Telr payment status
  Future<Map<String, dynamic>> checkTelrPaymentStatus(
      String transactionRef) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }

      // Note: This might need to be implemented in your backend
      final response = await _dio.post(
        '/payment/telr/status',
        data: {
          'transaction_ref': transactionRef,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to check payment status: ${e.message}');
    }
  }

  // ✅ ENDPOINT 4: Handle Telr payment callback (for webhook)
  Future<Map<String, dynamic>> handleTelrCallback(
      Map<String, dynamic> callbackData) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }

      final response = await _dio.post(
        '/payment/telr/callback',
        data: callbackData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to process callback: ${e.message}');
    }
  }

  // ================== REGULAR PAYMENT ENDPOINTS ==================

  Future<List<dynamic>> getPayments({
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }

      final response = await _dio.post(
        '/payment/paginated/',
        queryParameters: {
          'skip': skip.toString(),
          'limit': limit.toString(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          return List<dynamic>.from(data['data']);
        }
        return [];
      } else {
        throw Exception('Failed to load payments: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load payments: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> makePayment({
    required double amount,
    required String bank,
    required String transactionId,
    required DateTime transactionDate,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    try {
      final token = await _getAuthToken();
      final userId = await _getUserId();

      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final formData = FormData.fromMap({
        'amount': amount.toString(),
        'bank': bank,
        'transaction_id': transactionId,
        'transaction_date': transactionDate.toIso8601String(),
        'user_profile_id': userId,
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/payment/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        final res = response.data;
        if (res is Map && res['data'] is Map) {
          return Map<String, dynamic>.from(res['data']);
        }
        return {};
      } else {
        throw Exception('Failed to create payment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create payment: ${e.message}');
    }
  }

  // In your employer PaymentService, update the getUserPayments method:

  Future<List<dynamic>> getUserPayments() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login again.');
      }

      final response = await _dio.get(
        '/payment/',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle the invoice data structure (same as employee page)
        if (data is List) {
          return data; // This returns invoice data
        }
        return [];
      } else {
        throw Exception('Failed to load user payments: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load user payments: ${e.message}');
    }
  }
}
