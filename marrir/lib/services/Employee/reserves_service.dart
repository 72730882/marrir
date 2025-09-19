import 'package:dio/dio.dart';
import 'package:marrir/Dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReserveService {
  static final Dio _dio = DioClient().dio;

  Future<List<ReserveBatchItem>> getMyIncomingReserves({
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) throw Exception("Not authenticated");

      final response = await _dio.post(
        '/reserve/my-reserves',
        queryParameters: {"skip": skip, "limit": limit},
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      final List items = (response.data?['data'] as List?) ?? [];
      return items.map((e) => ReserveBatchItem.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReserveDetailItem>> getMyIncomingReservesDetail({
    required int batchReserveId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) throw Exception("Not authenticated");

      final response = await _dio.post(
        '/reserve/my-reserves/detail/paginated',
        data: {"batch_reserve_id": batchReserveId},
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      final List items = (response.data?['data'] as List?) ?? [];
      return items.map((e) => ReserveDetailItem.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

class ReserveBatchItem {
  final int id;
  final String? reserverFirstName;
  final String? reserverLastName;
  final String? reserverRole;
  final String? createdAt; // ISO date string
  final String? updatedAt;

  ReserveBatchItem({
    required this.id,
    this.reserverFirstName,
    this.reserverLastName,
    this.reserverRole,
    this.createdAt,
    this.updatedAt,
  });

  String get reserverFullName {
    final f = reserverFirstName?.trim() ?? '';
    final l = reserverLastName?.trim() ?? '';
    final full = '$f $l'.trim();
    return full.isEmpty ? 'Unknown' : full;
  }

  factory ReserveBatchItem.fromJson(Map<String, dynamic> json) {
    final reserver = json['reserver'] as Map<String, dynamic>?;

    return ReserveBatchItem(
      id: json['id'] as int,
      reserverFirstName: reserver?['first_name'] as String?,
      reserverLastName: reserver?['last_name'] as String?,
      reserverRole: reserver?['role'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class ReserveDetailItem {
  final int id;
  final int cvId;
  final String? englishFullName;
  final String? status;
  final String? reason;
  final String? createdAt;

  ReserveDetailItem({
    required this.id,
    required this.cvId,
    this.englishFullName,
    this.status,
    this.reason,
    this.createdAt,
  });

  factory ReserveDetailItem.fromJson(Map<String, dynamic> json) {
    final cv = json['cv'] as Map<String, dynamic>?;

    return ReserveDetailItem(
      id: json['id'] as int,
      cvId: json['cv_id'] as int,
      englishFullName: cv?['english_full_name'] as String?,
      status: json['status'] as String?,
      reason: json['reason'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
