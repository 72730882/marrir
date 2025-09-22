// services/job_service.dart
import 'package:dio/dio.dart';
import 'package:marrir/Dio/dio.dart';
import 'package:marrir/services/Employer/get_comany_info.dart'; // Import the company service

class JobService {
  final DioClient _dioClient = DioClient();
  final CompanyService _companyService =
      CompanyService(); // Initialize company service

  Future<List<dynamic>> getJobs({
    int skip = 0,
    int limit = 10,
    String? search,
    String? startDate,
    String? endDate,
    bool includeCompanyInfo = true, // Add this parameter
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/job/paginated',
        data: {
          if (search != null && search.isNotEmpty) "search": search,
          if (startDate != null) "start_date": startDate,
          if (endDate != null) "end_date": endDate,
        },
        queryParameters: {
          "skip": skip,
          "limit": limit,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data') &&
            responseData['data'] is List) {
          var jobs = responseData['data'] as List;

          // ADD THIS - Enhance jobs with company info if requested
          if (includeCompanyInfo && jobs.isNotEmpty) {
            try {
              jobs = await _companyService.enhanceJobsWithCompanyInfo(jobs);
            } catch (e) {
              print('⚠️ Warning: Failed to enhance jobs with company info: $e');
              // Continue without company info
            }
          }

          return jobs;
        }
      }
      return [];
    } on DioException catch (e) {
      print('❌ Error fetching jobs: ${e.message}');
      if (e.response != null) {
        print('❌ Response data: ${e.response?.data}');
        print('❌ Response status: ${e.response?.statusCode}');

        if (e.response?.statusCode == 422) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData.containsKey('detail')) {
            throw Exception('Validation error: ${errorData['detail']}');
          } else if (errorData is Map && errorData.containsKey('message')) {
            throw Exception('Validation error: ${errorData['message']}');
          }
        }
      }
      throw Exception('Failed to load jobs: ${e.message}');
    }
  }

  // ADD THIS METHOD - to get job with company info
  Future<Map<String, dynamic>> getJobWithCompanyInfo(int jobId) async {
    try {
      final response = await _dioClient.dio.post(
        '/job/single',
        data: {"id": jobId},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          final job = responseData['data'] as Map<String, dynamic>;

          try {
            final enhancedJobs =
                await _companyService.enhanceJobsWithCompanyInfo([job]);
            return enhancedJobs.isNotEmpty ? enhancedJobs.first : job;
          } catch (e) {
            print('⚠️ Warning: Failed to enhance job with company info: $e');
            return job; // Return job without company info
          }
        }
      }
      return {};
    } on DioException catch (e) {
      print('❌ Error fetching job with company info: ${e.message}');
      throw Exception('Failed to get job details: ${e.message}');
    }
  }

  // The rest of your methods remain exactly the same...
  Future<Map<String, dynamic>> createJob(Map<String, dynamic> jobData) async {
    try {
      // Only include fields that the backend actually accepts
      final requiredFields = [
        'name',
        'description',
        'amount',
        'location',
        'type'
      ];

      for (var field in requiredFields) {
        if (jobData[field] == null || jobData[field].toString().isEmpty) {
          throw Exception('Missing required field: $field');
        }
      }

      final validJobTypes = [
        'contractual',
        'temporary',
        'full_time',
        'recruiting_worker',
        'worker_transport_service',
        'hiring_worker'
      ];

      final jobType = jobData['type'].toString().toLowerCase();
      if (!validJobTypes.contains(jobType)) {
        throw Exception(
            'Invalid job type. Must be one of: ${validJobTypes.join(", ")}');
      }

      if (jobData['amount'] is String) {
        jobData['amount'] = int.tryParse(jobData['amount']);
        if (jobData['amount'] == null) {
          throw Exception('Amount must be a valid number');
        }
      }

      final filteredJobData = {
        'name': jobData['name'],
        'description': jobData['description'],
        'amount': jobData['amount'],
        'location': jobData['location'],
        'type': jobData['type'],
        if (jobData['occupation'] != null) 'occupation': jobData['occupation'],
        if (jobData['education_status'] != null)
          'education_status': jobData['education_status'],
        if (jobData['is_open'] != null) 'is_open': jobData['is_open'],
      };

      final response = await _dioClient.dio.post(
        '/job/',
        data: filteredJobData,
      );

      if (response.statusCode == 201) {
        return response.data ?? {};
      } else {
        throw Exception('Failed to create job: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error creating job: ${e.message}');
      if (e.response != null) {
        print('❌ Response: ${e.response?.data}');
        print('❌ Status: ${e.response?.statusCode}');

        if (e.response?.statusCode == 422) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData.containsKey('detail')) {
            final details = errorData['detail'];
            if (details is List) {
              final errorMessages = details.map((error) {
                if (error is Map) {
                  return error['msg'] ?? 'Validation error';
                }
                return error.toString();
              }).join(', ');
              throw Exception('Validation errors: $errorMessages');
            }
            throw Exception('Validation error: ${errorData['detail']}');
          }
        }
      }
      throw Exception('Failed to create job: ${e.message}');
    }
  }

  // Helper methods for UI
  static const Map<String, String> occupationTypes = {
    'mobile': 'Mobile',
    'web': 'Web',
    'design': 'Design',
    'marketing': 'Marketing',
    'strategy': 'Strategy',
    'analytics': 'Analytics',
    'engineering': 'Engineering',
    'sales': 'Sales',
  };

  static const Map<String, String> workLocationTypes = {
    'remote': 'Remote',
    'on_site': 'On-site',
    'hybrid': 'Hybrid',
  };

  static String getOccupationDisplayName(String value) {
    return occupationTypes[value] ?? value;
  }

  static String getWorkLocationDisplayName(String value) {
    return workLocationTypes[value] ?? value;
  }

  Future<Map<String, dynamic>> getJobDetails(int jobId) async {
    try {
      final response = await _dioClient.dio.post(
        '/job/single',
        data: {"id": jobId},
      );

      if (response.statusCode == 200) {
        return response.data ?? {};
      } else {
        throw Exception('Failed to get job details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error getting job details: ${e.message}');
      throw Exception('Failed to get job details: ${e.message}');
    }
  }

  Future<void> updateJob(int jobId, Map<String, dynamic> updateData) async {
    try {
      final response = await _dioClient.dio.patch(
        '/job/',
        data: {
          "filter": {"id": jobId},
          "update": updateData,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update job: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error updating job: ${e.message}');
      throw Exception('Failed to update job: ${e.message}');
    }
  }

  Future<void> bulkUploadJobs(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: 'jobs.xlsx'),
      });

      final response = await _dioClient.dio.post(
        '/job/bulk',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to upload jobs: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error uploading jobs: ${e.message}');
      if (e.response != null) {
        print('❌ Response: ${e.response?.data}');
      }
      throw Exception('Failed to upload jobs: ${e.message}');
    }
  }

  Future<void> closeJob(int jobId) async {
    try {
      final response = await _dioClient.dio.delete(
        '/job/close',
        data: {"id": jobId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to close job: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error closing job: ${e.message}');
      throw Exception('Failed to close job: ${e.message}');
    }
  }

  Future<void> deleteJob(int jobId) async {
    try {
      final response = await _dioClient.dio.delete(
        '/job/',
        data: {"id": jobId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete job: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Error deleting job: ${e.message}');
      throw Exception('Failed to delete job: ${e.message}');
    }
  }
}
