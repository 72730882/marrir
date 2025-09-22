// services/employee_service.dart
import 'package:dio/dio.dart';
import 'package:marrir/Dio/dio.dart';
import 'dart:convert';

class EmployeeService {
  final DioClient _dioClient = DioClient();

  Future<List<dynamic>> getEmployees(String managerId) async {
    try {
      print('🔍 Fetching employees for manager: $managerId');

      // Backend expects manager_id as a query parameter, not in body
      final response = await _dioClient.dio.post(
        '/user/employees?manager_id=$managerId&skip=0&limit=100',
      );

      print('📦 Raw API Response: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Backend returns: {"status_code": 200, "message": "...", "error": false, "data": [...], "count": X}
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data') &&
            responseData['data'] is List) {
          final employees = responseData['data'] as List;
          print('✅ Found ${employees.length} employees');
          return employees;
        } else {
          print('⚠️ Unexpected response structure: $responseData');
          return [];
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.message}');
      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');
      }
      throw Exception('Failed to load employees: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to load employees: $e');
    }
  }

  String _formatPhoneNumber(String phoneNumber, String countryCode) {
    // Remove any non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // If it starts with +, assume it's already in international format
    if (digitsOnly.startsWith('+')) {
      return digitsOnly;
    }

    // If it starts with country code without +, add +
    if (digitsOnly.startsWith(countryCode.replaceAll('+', ''))) {
      return '+$digitsOnly';
    }

    // For local numbers, add country code
    // Remove leading 0 if present
    if (digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.substring(1);
    }

    return '+$countryCode$digitsOnly';
  }

  Future<Map<String, dynamic>> addEmployee(
      Map<String, dynamic> employeeData) async {
    try {
      print('➕ Adding employee: $employeeData');

      // Format phone number to E.164 format for Ethiopia (+251)
      String formattedPhoneNumber = _formatPhoneNumber(
          employeeData["phone_number"], "251" // Ethiopia country code
          );

      print('📱 Formatted phone number: $formattedPhoneNumber');

      // BACKEND EXPECTS EXACTLY THIS STRUCTURE based on UserCreateSchema:
      final dataToSend = {
        "first_name": employeeData["first_name"],
        "last_name": employeeData["last_name"],
        "email": employeeData["email"],
        "phone_number": formattedPhoneNumber, // Use formatted number
        "country": employeeData["country"] ?? "Ethiopia",
        "role": "employee",
        "password": employeeData["password"],
      };

      // Remove any null values to avoid sending empty fields
      dataToSend.removeWhere((key, value) => value == null);

      print('📤 Sending to backend: $dataToSend');
      print('📤 JSON encoded: ${jsonEncode(dataToSend)}');

      final response = await _dioClient.dio.post(
        '/user/employee/create',
        data: dataToSend,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print('📦 Add Employee Response: ${response.data}');

      if (response.statusCode == 201) {
        final responseData = response.data;
        print('✅ Employee added successfully');
        return responseData['data'] ?? {};
      } else {
        print('❌ Failed to add employee: ${response.statusCode}');
        throw Exception('Failed to add employee: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error adding employee: ${e.message}');
      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');

        if (e.response?.statusCode == 422) {
          // Show validation errors
          final errorData = e.response?.data;
          if (errorData is Map<String, dynamic> &&
              errorData.containsKey('detail')) {
            throw Exception('Validation error: ${errorData['detail']}');
          }
          throw Exception(
              'Invalid data format. Please check all required fields.');
        }
      }
      throw Exception('Failed to add employee: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      throw Exception('Failed to add employee: $e');
    }
  }

  Future<Map<String, dynamic>> getEmployeeDetail(String employeeId) async {
    try {
      print('🔍 Getting details for employee: $employeeId');

      // Backend expects employee_id in the request body
      final response = await _dioClient.dio.post(
        '/user/employee',
        data: {'employee_id': employeeId},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          print('✅ Employee details retrieved');
          return responseData['data'] ?? {};
        } else {
          return responseData;
        }
      } else {
        throw Exception(
            'Failed to get employee details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get employee details: ${e.message}');
    }
  }
}
