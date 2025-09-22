// services/rating_service.dart
import 'package:dio/dio.dart';
import 'package:marrir/Dio/dio.dart';

class RatingService {
  final DioClient _dioClient = DioClient();

  Future<List<dynamic>> getEmployeeRatings() async {
    try {
      final response = await _dioClient.dio.post(
        '/rating/employees',
        data: {}, // Empty data since the endpoint doesn't require filters
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data') &&
            responseData['data'] is List) {
          return responseData['data'] as List;
        }
      }
      return [];
    } on DioException catch (e) {
      print('❌ Error fetching employee ratings: ${e.message}');
      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      return [];
    }
  }

  Future<Map<String, dynamic>> getUserRating(String userId) async {
    try {
      final response = await _dioClient.dio.post(
        '/rating/user',
        data: {"user_id": userId},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return responseData['data'] as Map<String, dynamic>;
        }
      }
      return {};
    } on DioException catch (e) {
      print('❌ Error fetching user rating: ${e.message}');
      return {};
    }
  }

  Future<bool> addRating(Map<String, dynamic> ratingData) async {
    try {
      final response = await _dioClient.dio.post(
        '/rating/',
        data: ratingData,
      );

      return response.statusCode == 201;
    } on DioException catch (e) {
      print('❌ Error adding rating: ${e.message}');
      return false;
    }
  }
}
