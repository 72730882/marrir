// services/company_service.dart
import 'package:dio/dio.dart';
import 'package:marrir/Dio/dio.dart';

class CompanyService {
  final DioClient _dioClient = DioClient();

  Future<Map<String, dynamic>> getCompanyInfoByUserId(String userId) async {
    try {
      print('🔄 Fetching company info for user: $userId');

      final response = await _dioClient.dio.post(
        '/company_info/single',
        data: {"user_id": userId},
      );

      print('✅ Company info response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data') &&
            responseData['data'] != null) {
          print('📦 Company data found');
          return responseData['data'] as Map<String, dynamic>;
        }
      }
      print('⚠️ No company data found or empty response');
      return {};
    } on DioException catch (e) {
      print('❌ Error fetching company info for user $userId: ${e.message}');
      if (e.response != null) {
        print('❌ Response status: ${e.response?.statusCode}');
        print('❌ Response data: ${e.response?.data}');
        print('❌ Request URL: ${e.response?.requestOptions.uri}');
      }
      return {};
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {};
    }
  }

  // Alternative method that doesn't rely on the potentially broken endpoint
  Future<Map<String, dynamic>> getCompanyInfoSafe(String userId) async {
    // First try the main endpoint
    final companyInfo = await getCompanyInfoByUserId(userId);

    // If that fails or returns empty, try a fallback approach
    if (companyInfo.isEmpty) {
      print('🔄 Trying fallback company info approach...');
      // You could implement alternative ways to get company info here
      // For example, if you have other endpoints or cached data
    }

    return companyInfo;
  }

  Future<Map<String, dynamic>> getCompanyInfoForJob(dynamic job) async {
    try {
      final postedBy = job['posted_by']?.toString();
      if (postedBy == null || postedBy == 'N/A' || postedBy.isEmpty) {
        return {};
      }

      return await getCompanyInfoSafe(postedBy);
    } catch (e) {
      print('❌ Error getting company info for job: $e');
      return {};
    }
  }

  Future<List<dynamic>> enhanceJobsWithCompanyInfo(List<dynamic> jobs) async {
    final enhancedJobs = <dynamic>[];
    final companyCache = <String, Map<String, dynamic>>{};

    for (var job in jobs) {
      try {
        final postedBy = job['posted_by']?.toString();
        if (postedBy == null || postedBy == 'N/A' || postedBy.isEmpty) {
          enhancedJobs.add(job);
          continue;
        }

        // Check cache first
        if (!companyCache.containsKey(postedBy)) {
          companyCache[postedBy] = await getCompanyInfoSafe(postedBy);
        }

        final companyInfo = companyCache[postedBy]!;
        final enhancedJob = {
          ...job,
          'company_info': companyInfo,
          'company_name': getCompanyDisplayName(companyInfo),
          'company_logo': companyInfo['company_logo'],
          'company_industry': companyInfo['industry'],
          'company_size': companyInfo['company_size'],
        };

        enhancedJobs.add(enhancedJob);
      } catch (e) {
        print('❌ Error enhancing job with company info: $e');
        enhancedJobs.add(job);
      }
    }

    return enhancedJobs;
  }

  String getCompanyDisplayName(Map<String, dynamic> companyInfo) {
    if (companyInfo.isEmpty) return 'Unknown Company';

    final companyName = companyInfo['company_name'];
    if (companyName != null && companyName.toString().isNotEmpty) {
      return companyName.toString();
    }

    final firstName = companyInfo['first_name'] ?? '';
    final lastName = companyInfo['last_name'] ?? '';
    final individualName = '$firstName $lastName'.trim();

    return individualName.isNotEmpty ? individualName : 'Unknown Company';
  }

  String getCompanyLocation(Map<String, dynamic> companyInfo) {
    return companyInfo['location']?.toString() ?? 'Location not specified';
  }

  String getCompanyIndustry(Map<String, dynamic> companyInfo) {
    return companyInfo['industry']?.toString() ?? 'Industry not specified';
  }
}
