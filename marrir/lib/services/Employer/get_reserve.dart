import 'package:dio/dio.dart';
import 'package:marrir/model/recerve_model.dart';
import 'package:marrir/Dio/dio.dart';

class ReserveHistoryService {
  final DioClient dioClient;

  ReserveHistoryService(this.dioClient);

  Dio get dio => dioClient.dio;

  void _logError(String method, dynamic error) {
    print('❌ Error in $method: $error');
    if (error is DioException) {
      print('❌ Dio Error Type: ${error.type}');
      print('❌ Dio Error Message: ${error.message}');
      print('❌ Response Status: ${error.response?.statusCode}');
      print('❌ Response Data: ${error.response?.data}');
      print('❌ Request Data: ${error.requestOptions.data}');
    }
  }

  // FIXED: Match exact backend endpoint structure for /reserve/history
  Future<ApiResponse<List<ReserveHistory>>> getReserveHistory({
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      // Backend expects filters as query parameters, not in body
      final Map<String, dynamic> queryParams = {
        'skip': skip,
        'limit': limit,
      };

      print('📡 Calling /reserve/history with query: $queryParams');

      // Backend expects POST with query parameters, not data body
      final response = await dio.post(
        '/reserve/history',
        queryParameters: queryParams, // Use queryParameters instead of data
      );

      print('✅ Response status: ${response.statusCode}');
      print('✅ Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> historyData = data['data'] ?? [];

        final history = historyData.map((item) {
          try {
            return ReserveHistory.fromJson(item);
          } catch (e) {
            print('❌ Error parsing ReserveHistory: $e');
            print('❌ Problematic item: $item');
            return ReserveHistory(
              id: item['id'] ?? 0,
              reserverName: 'Unknown',
              createdAt: DateTime.now(),
              reserves: [],
            );
          }
        }).toList();

        return ApiResponse(
          success: true,
          data: history,
          message: data['message'] ?? 'Success',
          count: data['count'] ?? history.length,
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['message'] ?? 'Failed to fetch reserve history',
        );
      }
    } on DioException catch (e) {
      _logError('getReserveHistory', e);
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ??
            'Network error occurred: ${e.message}',
      );
    } catch (e) {
      _logError('getReserveHistory', e);
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  // FIXED: Match exact backend endpoint structure for /reserve/my-reserves
  Future<ApiResponse<List<IncomingReserveRequest>>> getIncomingReserveRequests({
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      // Backend expects query parameters, not data body
      final Map<String, dynamic> queryParams = {
        'skip': skip,
        'limit': limit,
      };

      print('📡 Calling /reserve/my-reserves with query: $queryParams');

      final response = await dio.post(
        '/reserve/my-reserves',
        queryParameters: queryParams, // Use queryParameters
      );

      print('✅ Response status: ${response.statusCode}');
      print('✅ Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> requestsData = data['data'] ?? [];

        final requests = requestsData.map((item) {
          try {
            return IncomingReserveRequest.fromJson(item);
          } catch (e) {
            print('❌ Error parsing IncomingReserveRequest: $e');
            print('❌ Problematic item: $item');
            return IncomingReserveRequest(
              id: item['id'] ?? 0,
              reserverName: 'Unknown',
              reserverRole: 'Unknown',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        }).toList();

        return ApiResponse(
          success: true,
          data: requests,
          message: data['message'] ?? 'Success',
          count: data['count'] ?? requests.length,
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['message'] ?? 'Failed to fetch incoming requests',
        );
      }
    } on DioException catch (e) {
      _logError('getIncomingReserveRequests', e);
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ??
            'Network error occurred: ${e.message}',
      );
    } catch (e) {
      _logError('getIncomingReserveRequests', e);
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  // FIXED: Match exact backend endpoint structure for /reserve/my-reserves/detail/paginated
  Future<ApiResponse<List<ReserveDetail>>> getReserveRequestDetails(
    int batchReserveId,
  ) async {
    try {
      // Backend expects batch_reserve_id as a field in the data body
      final Map<String, dynamic> requestData = {
        'batch_reserve_id': batchReserveId,
      };

      print(
          '📡 Calling /reserve/my-reserves/detail/paginated with data: $requestData');

      final response = await dio.post(
        '/reserve/my-reserves/detail/paginated',
        data: requestData,
      );

      print('✅ Response status: ${response.statusCode}');
      print('✅ Response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> detailsData = data['data'] ?? [];
        final details =
            detailsData.map((item) => ReserveDetail.fromJson(item)).toList();

        return ApiResponse(
          success: true,
          data: details,
          message: data['message'] ?? 'Success',
          count: data['count'] ?? details.length,
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['message'] ?? 'Failed to fetch reserve details',
        );
      }
    } on DioException catch (e) {
      _logError('getReserveRequestDetails', e);
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      _logError('getReserveRequestDetails', e);
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  // FIXED: Match exact backend endpoint structure for PATCH /reserve/
  Future<ApiResponse<void>> updateReserveStatus({
    required int batchReserveId,
    required List<int> cvIds,
    required String status,
    String? reason,
  }) async {
    try {
      // Exact structure matching ReserveUpdateSchema
      final Map<String, dynamic> requestData = {
        'filter': {
          'batch_id': batchReserveId,
          'cv_ids': cvIds,
        },
        'update': {
          'status': status,
          if (reason != null) 'reason': reason,
        },
      };

      print('📡 Calling PATCH /reserve/ with data: $requestData');

      final response = await dio.patch(
        '/reserve/',
        data: requestData,
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message:
              response.data['message'] ?? 'Reserve status updated successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['message'] ?? 'Failed to update reserve status',
        );
      }
    } on DioException catch (e) {
      _logError('updateReserveStatus', e);
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      _logError('updateReserveStatus', e);
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  // Test endpoint connectivity
  Future<ApiResponse<void>> testEndpoints() async {
    try {
      // Test /reserve/history
      print('🔍 Testing /reserve/history endpoint...');
      final historyResponse = await dio.post(
        '/reserve/history',
        queryParameters: {'skip': 0, 'limit': 5},
      );
      print('✅ /reserve/history response: ${historyResponse.statusCode}');

      // Test /reserve/my-reserves
      print('🔍 Testing /reserve/my-reserves endpoint...');
      final myReservesResponse = await dio.post(
        '/reserve/my-reserves',
        queryParameters: {'skip': 0, 'limit': 5},
      );
      print(
          '✅ /reserve/my-reserves response: ${myReservesResponse.statusCode}');

      return ApiResponse(success: true, message: 'All endpoints are reachable');
    } on DioException catch (e) {
      _logError('testEndpoints', e);
      return ApiResponse(
        success: false,
        message: 'Endpoint test failed: ${e.message}',
      );
    }
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? count;

  ApiResponse({
    required this.success,
    this.message = '',
    this.data,
    this.count,
  });
}
