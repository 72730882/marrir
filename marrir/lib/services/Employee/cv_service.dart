import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:marrir/Dio/dio.dart';

class CVService {
  static final Dio _dio = DioClient().dio;

  // In your CV service file
  static Future<Map<String, dynamic>> uploadPassport({
    required File passportFile,
    required String userId, // Make this required
    required String token,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(passportFile.path,
            filename: 'passport_${DateTime.now().millisecondsSinceEpoch}.jpg'),
        'user_id': userId, // Always include user_id
      });

      final response = await _dio.post(
        "/cv/passport",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = response.data;
        if ((res["error"] == false || res["id"] != null) &&
            res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception(res["message"] ?? "Failed to upload passport");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Passport upload failed: ${e.response?.data ?? e.message}");
    }
  }

// New method: submit full CV form
  // In your CVService class
  static Future<Map<String, dynamic>> submitCVForm({
    required String nationalId,
    required String passportNumber,
    required String dateIssued,
    required String placeIssued,
    required String dateExpiry,
    required String nationality,
    File? headPhoto,
    File? fullBodyPhoto,
    File? introVideo,
    required String token,
    required String userId,

    // 🔹 New fields for languages
    String? english,
    String? amharic,
    String? arabic,
  }) async {
    try {
      final Map<String, dynamic> cvData = {
        "user_id": userId,
        "national_id": nationalId,
        "passport_number": passportNumber,
        "date_issued": dateIssued,
        "place_issued": placeIssued,
        "date_of_expiry": dateExpiry,
        "nationality": nationality,

        // 🔹 Include language levels (backend expects LanguageProficiencySchema enum)
        "english": english,
        "amharic": amharic,
        "arabic": arabic,
      };

      final formData = FormData.fromMap({
        "cv_data_json": jsonEncode(cvData),
        if (headPhoto != null)
          "head_photo": await MultipartFile.fromFile(
            headPhoto.path,
            filename: 'head_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        if (fullBodyPhoto != null)
          "full_body_photo": await MultipartFile.fromFile(
            fullBodyPhoto.path,
            filename: 'full_body_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        if (introVideo != null)
          "intro_video": await MultipartFile.fromFile(
            introVideo.path,
            filename: 'intro_${DateTime.now().millisecondsSinceEpoch}.mp4',
          ),
      });

      final response = await _dio.post(
        "/cv/",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = response.data;
        if ((res["error"] == false || res["data"] != null) &&
            res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception(res["message"] ?? "Failed to submit CV form");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("CV submission failed: ${e.response?.data ?? e.message}");
    }
  }

  /// Submit only personal info fields
  static Future<Map<String, dynamic>> submitPersonalInfo({
    required String userId,
    required String token,
    required String amharicFullName,
    required String englishFullName,
    required String arabicFullName,
    required String sex,
    required String email,
    required String phone,
    required String height,
    required String weight,
    required String maritalStatus,
    required String children,
    required String skinTone,
    required String placeOfBirth,
    required String dateOfBirth,
    required String religion,
  }) async {
    try {
      final cvData = {
        "user_id": userId,
        "amharic_full_name": amharicFullName,
        "english_full_name": englishFullName,
        "arabic_full_name": arabicFullName,
        "sex": sex,
        "email": email,
        "phone_number": phone,
        "height": height,
        "weight": weight,
        "marital_status": maritalStatus,
        "number_of_children": int.tryParse(children),
        "skin_tone": skinTone,
        "place_of_birth": placeOfBirth,
        "date_of_birth": dateOfBirth,
        "religion": religion,
      };

      final formData = FormData.fromMap({
        "cv_data_json": jsonEncode(cvData),
      });

      final response = await _dio.post(
        "/cv/",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = response.data;
        if (res["error"] == false && res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception(res["message"] ?? "Failed to submit personal info");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Personal info submission failed: ${e.response?.data ?? e.message}");
    }
  }

  // ================= Address Info Submit =================
  static Future<Map<String, dynamic>> submitAddressInfo({
    required String userId,
    required String token,
    required String country,
    required String region,
    required String city,
    required String street,
    String? street2,
    String? street3,
    String? zipCode,
    String? houseNumber,
    String? poBox,
  }) async {
    try {
      final cvData = {
        "user_id": userId,
        "address": {
          "country": country,
          "region": region,
          "city": city,
          "street": street,
          "street2": street2,
          "street3": street3,
          "zip_code": zipCode,
          "house_no": houseNumber,
          "po_box": poBox != null ? int.tryParse(poBox) : null,
        },
      };

      final formData = FormData.fromMap({
        "cv_data_json": jsonEncode(cvData),
      });

      final response = await _dio.post(
        "/cv/",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = response.data;
        if (res["error"] == false && res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception(res["message"] ?? "Failed to submit address info");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Address info submission failed: ${e.response?.data ?? e.message}");
    }
  }

  static Future<Map<String, dynamic>> submitSummaryInfo({
    required String userId,
    required String token,
    required String summary,
    String? salaryExpectation,
    String? currency,
    List<String>? skills,
  }) async {
    try {
      final cvData = {
        "user_id": userId,
        "summary": summary,
        "expected_salary": salaryExpectation,
        "currency": currency,
        "skills_one": skills != null && skills.isNotEmpty ? skills[0] : null,
        "skills_two": skills != null && skills.length > 1 ? skills[1] : null,
        "skills_three": skills != null && skills.length > 2 ? skills[2] : null,
        "skills_four": skills != null && skills.length > 3 ? skills[3] : null,
        "skills_five": skills != null && skills.length > 4 ? skills[4] : null,
        "skills_six": skills != null && skills.length > 5 ? skills[5] : null,
      };

      final formData = FormData.fromMap({
        "cv_data_json": jsonEncode(cvData),
      });

      final response = await _dio.post(
        "/cv/",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = response.data;
        if (res["error"] == false && res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception(res["message"] ?? "Failed to submit summary info");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Summary info submission failed: ${e.response?.data ?? e.message}");
    }
  }

  /// Submit or update CV education data
  static Future<Map<String, dynamic>> submitEducationInfo({
    required String userId,
    required String token,
    String? highestLevel, // backend: highest_level
    String? institutionName, // backend: institution_name
    String? country,
    String? city,
    String? grade,
    String? occupationCategory, // backend: occupation_category
    String? occupation, // backend: occupation
  }) async {
    try {
      final cvData = {
        "user_id": userId,
        "education": {
          "highest_level": highestLevel,
          "institution_name": institutionName,
          "country": country,
          "city": city,
          "grade": grade,
        },
        "occupation_category": occupationCategory,
        "occupation": occupation,
      };

      final formData = FormData.fromMap({
        "cv_data_json": jsonEncode(cvData),
      });

      final response = await _dio.post(
        "/cv/", // same endpoint as summary
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = response.data;
        if (res["error"] == false) {
          return Map<String, dynamic>.from(res["data"] ?? {});
        } else {
          throw Exception(res["message"] ?? "Failed to submit education info");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Education info submission failed: ${e.response?.data ?? e.message}");
    }
  }

  /// Submit or update work experiences
  static Future<Map<String, dynamic>> submitWorkExperience({
    required String userId,
    required String token,
    required String companyName,
    required String country,
    required String city,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final cvData = {
        "user_id": userId,
        "work_experiences": [
          {
            "company_name": companyName,
            "country": country,
            "city": city,
            "start_date": startDate,
            "end_date": endDate,
          }
        ]
      };

      final formData = FormData.fromMap({
        "cv_data_json": jsonEncode(cvData),
      });

      final response = await _dio.post(
        "/cv/",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = response.data;
        if (res["error"] == false && res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception(res["message"] ?? "Failed to submit work experience");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Work experience submission failed: ${e.response?.data ?? e.message}");
    }
  }

  /// Submit or update references
  static Future<Map<String, dynamic>> submitReference({
    required String userId,
    required String token,
    required String name,
    required String phoneNumber,
    String? email,
    String? birthDate,
    String? gender,
    String? country,
    String? city,
    String? subCity,
    String? zone,
    String? houseNo,
    int? poBox,
    String? summary, // ✅ Added summary
  }) async {
    try {
      final cvData = {
        "user_id": userId,
        "summary": summary, // ✅ Correct placement according to schema
        "references": [
          {
            "name": name,
            "phone_number": phoneNumber,
            "email": email,
            "birth_date": birthDate,
            "gender": gender,
            "country": country,
            "city": city,
            "sub_city": subCity,
            "zone": zone,
            "house_no": houseNo,
            "po_box": poBox,
          }
        ]
      };

      final formData = FormData.fromMap({
        "cv_data_json": jsonEncode(cvData),
      });

      final response = await _dio.post(
        "/cv/",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = response.data;
        if (res["error"] == false && res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception(res["message"] ?? "Failed to submit reference");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception(
          "Reference submission failed: ${e.response?.data ?? e.message}");
    }
  }

  /// Submit or update additional contact/social links
  static Future<Map<String, dynamic>> submitAdditionalContacts({
    required String userId, // ✅ pass userId explicitly
    required String token, // ✅ pass token explicitly
    String? facebook,
    String? x,
    String? instagram,
    String? telegram,
    String? tiktok,
  }) async {
    try {
      final cvData = {
        "user_id": userId,
        "facebook": facebook,
        "x": x,
        "instagram": instagram,
        "telegram": telegram,
        "tiktok": tiktok,
      };

      final formData = FormData.fromMap({
        "cv_data_json": jsonEncode(cvData),
      });

      final response = await _dio.post(
        "/cv/", // endpoint to update CV
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = response.data;
        if (res["error"] == false && res["data"] != null) {
          return Map<String, dynamic>.from(res["data"]);
        } else {
          throw Exception(
              res["message"] ?? "Failed to submit additional contacts");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Submission failed: ${e.response?.data ?? e.message}");
    }
  }
}
