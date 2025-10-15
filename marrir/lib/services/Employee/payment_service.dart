// services/payment_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  // Create a separate Dio instance without baseUrl
  static final Dio _paymentDio = Dio(BaseOptions(
    baseUrl: "https://api.marrir.com", // <-- add your domain only, no api/v1

    // baseUrl: "http://127.0.0.1:8000/",
    // baseUrl: "http://10.0.2.2:8000",
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // Get headers with authentication
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get user's payment invoices
  static Future<List<Map<String, dynamic>>> getUserPayments() async {
    try {
      final headers = await _getHeaders();

      final response = await _paymentDio.get(
        '/payment/', // no api/v1 prefix
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to load payments: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'Failed to load payments: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Failed to load payments: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }
}
