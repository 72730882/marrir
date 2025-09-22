// services/company_info_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:marrir/Dio/dio.dart';

class CompanyInfoService {
  static const String endpoint = '/company_info/';

  static Future<Map<String, dynamic>> createUpdateCompanyInfo({
    required Map<String, dynamic> companyData,
    File? companyLicense,
    File? companyLogo,
  }) async {
    try {
      final dioClient = DioClient();

      final formData = FormData.fromMap({
        'company_info_data_json': json.encode(companyData),
      });

      // Add files if they exist
      if (companyLicense != null) {
        formData.files.add(MapEntry(
          'company_license',
          await MultipartFile.fromFile(
            companyLicense.path,
            filename: companyLicense.path.split('/').last,
          ),
        ));
      }

      if (companyLogo != null) {
        formData.files.add(MapEntry(
          'company_logo',
          await MultipartFile.fromFile(
            companyLogo.path,
            filename: companyLogo.path.split('/').last,
          ),
        ));
      }

      final response = await dioClient.dio.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to save company info: ${e.response!.data}');
      } else {
        throw Exception('Failed to save company info: ${e.message}');
      }
    }
  }

  static Future<Map<String, dynamic>> getCompanyInfoProgress() async {
    try {
      final dioClient = DioClient();

      final response = await dioClient.dio.post('$endpoint/progress');

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to get progress: ${e.response!.data}');
      } else {
        throw Exception('Failed to get progress: ${e.message}');
      }
    }
  }

  static Future<Map<String, dynamic>> getSingleCompanyInfo() async {
    try {
      final dioClient = DioClient();

      final response = await dioClient.dio.post('$endpoint/single');

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to get company info: ${e.response!.data}');
      } else {
        throw Exception('Failed to get company info: ${e.message}');
      }
    }
  }
}
