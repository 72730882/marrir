// services/transfer_service.dart
import 'package:dio/dio.dart';
import 'package:marrir/Dio/dio.dart';
// import 'package:marrir/core/auth/auth_manager.dart';

class TransferService {
  final DioClient _dioClient = DioClient();
  // final AuthManager _authManager = AuthManager();

  // Get transfer statistics
  Future<Map<String, dynamic>> getTransferStats() async {
    try {
      final response = await _dioClient.dio.get(
        '/transfer/income',
      );

      if (response.statusCode == 200) {
        return response.data ?? {};
      }
      return {};
    } on DioException catch (e) {
      print('❌ Error fetching transfer stats: ${e.message}');
      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      return {};
    }
  }

  // Get incoming transfer requests
  Future<List<dynamic>> getIncomingTransfers() async {
    try {
      final response = await _dioClient.dio.post(
        '/transfer/requests/status/paginated',
        data: {},
        queryParameters: {
          "skip": 0,
          "limit": 10,
        },
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
      print('❌ Error fetching incoming transfers: ${e.message}');
      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
      }
      return [];
    }
  }

  // Get process transfer requests
  // Future<List<dynamic>> getProcessTransfers() async {
  //   try {
  //     final response = await _dioClient.dio.get(
  //       '/transfer/process',
  //     );

  //     if (response.statusCode == 200) {
  //       if (response.data is List) {
  //         return response.data as List;
  //       }
  //       return [];
  //     }
  //     return [];
  //   } on DioException catch (e) {
  //     print('❌ Error fetching process transfers: ${e.message}');
  //     if (e.response != null) {
  //       print('❌ Response status: ${e.response?.statusCode}');
  //       print('❌ Response data: ${e.response?.data}');
  //     }
  //     return [];
  //   }
  // }

  // Get agency/recruitment relationships
  Future<Map<String, dynamic>> getAgencyRecruitment() async {
    try {
      final response = await _dioClient.dio.get('/transfer/');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load agency recruitment data');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load agency recruitment data: ${e.message}');
    }
  }

  // Search employees for transfer
  Future<List<dynamic>> searchTransferEmployees() async {
    try {
      final response = await _dioClient.dio.get('/transfer/search');

      if (response.statusCode == 200) {
        return response.data['data'] ?? [];
      } else {
        throw Exception('Failed to search transfer employees');
      }
    } on DioException catch (e) {
      throw Exception('Failed to search transfer employees: ${e.message}');
    }
  }

  // Transfer employee
  Future<Map<String, dynamic>> transferEmployee({
    required List<String> userIds,
    required String receiverId,
    String? reason,
  }) async {
    try {
      final data = {
        "user_ids": userIds,
        "receiver_id": receiverId,
        "reason": reason,
      };

      final response = await _dioClient.dio.post(
        '/transfer/employee',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to transfer employee: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to transfer employee: ${e.message}');
    }
  }

  // Get transfer requests for current user
  Future<List<dynamic>> getIncomeTransfers() async {
    try {
      final response = await _dioClient.dio.get('/transfer/income');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load income transfers');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load income transfers: ${e.message}');
    }
  }

  // Get process transfers
  Future<List<dynamic>> getProcessTransfers() async {
    try {
      final response = await _dioClient.dio.get('/transfer/process');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load process transfers');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load process transfers: ${e.message}');
    }
  }

  // Update transfer request status
  Future<Map<String, dynamic>> updateTransferStatus({
    required List<int> transferRequestIds,
    required String status,
    String? reason,
  }) async {
    try {
      final data = {
        "transfer_request_id": transferRequestIds,
        "status": status,
        "reason": reason,
      };

      final response = await _dioClient.dio.post(
        '/transfer/request/status',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to update transfer status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update transfer status: ${e.message}');
    }
  }

  // Get transfer payment info
  Future<Map<String, dynamic>> getTransferPaymentInfo(
      List<int> transferRequestIds) async {
    try {
      final data = {
        "transfer_request_ids": transferRequestIds,
      };

      final response = await _dioClient.dio.post(
        '/transfer/info',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to get transfer payment info: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get transfer payment info: ${e.message}');
    }
  }

  // Initiate transfer payment
  Future<Map<String, dynamic>> payTransfer(List<int> transferRequestIds) async {
    try {
      final data = {
        "transfer_request_ids": transferRequestIds,
      };

      final response = await _dioClient.dio.post(
        '/transfer/pay',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
            'Failed to initiate transfer payment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to initiate transfer payment: ${e.message}');
    }
  }
}
