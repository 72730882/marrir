import 'package:dio/dio.dart';
import 'package:marrir/model/model.dart';
import 'package:marrir/Dio/dio.dart';

class ReserveService {
  final DioClient dioClient;

  ReserveService(this.dioClient);

  Dio get dio => dioClient.dio; // shortcut for easy access

  // Get unreserved employee CVs
  Future<ApiResponse<List<UnreservedEmployee>>> getUnreservedEmployees({
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final response = await dio.post(
        '/reserve/my-not-reserves',
        data: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> employeesData = data['data'] ?? [];
        final employees = employeesData
            .map((employee) => UnreservedEmployee.fromJson(employee))
            .toList();

        return ApiResponse(
          success: true,
          data: employees,
          message: data['message'] ?? 'Success',
          count: data['count'] ?? 0,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ??
              'Failed to fetch unreserved employees',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  // Search and filter employees
  Future<ApiResponse<List<UnreservedEmployee>>> searchEmployees({
    String? search,
    ReserveCVFilter? filters,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final response = await dio.post(
        '/reserve/employee/paginated',
        data: {
          'search': search,
          'filters': filters?.toJson(),
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> employeesData = data['data'] ?? [];
        final employees = employeesData
            .map((employee) => UnreservedEmployee.fromJson(employee))
            .toList();

        return ApiResponse(
          success: true,
          data: employees,
          message: data['message'] ?? 'Success',
          count: data['count'] ?? 0,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to search employees',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  // Reserve selected CVs
  Future<ApiResponse<void>> reserveCVs(List<int> cvIds) async {
    try {
      final response = await dio.post(
        '/reserve',
        data: {
          'cv_id': cvIds,
        },
      );

      if (response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: response.data['message'] ??
              'Reservation request sent successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Failed to reserve CVs',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data['message'] ?? 'Network error occurred',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'An unexpected error occurred',
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
