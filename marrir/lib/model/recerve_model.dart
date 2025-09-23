// Add to your recerve_model.dart
class ReserveHistory {
  final int id;
  final String reserverName;
  final DateTime createdAt;
  final List<ReserveDetail> reserves;
  final String? status;
  final String? reason;

  ReserveHistory({
    required this.id,
    required this.reserverName,
    required this.createdAt,
    required this.reserves,
    this.status,
    this.reason,
  });

  factory ReserveHistory.fromJson(Map<String, dynamic> json) {
    return ReserveHistory(
      id: json['id'] ?? 0,
      reserverName: json['reserver'] != null
          ? '${json['reserver']['first_name'] ?? ''} ${json['reserver']['last_name'] ?? ''}'
              .trim()
          : 'Unknown Reserver',
      createdAt:
          DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      reserves: (json['reserves'] as List<dynamic>? ?? [])
          .map((reserve) => ReserveDetail.fromJson(reserve))
          .toList(),
      status: json['status'],
      reason: json['reason'],
    );
  }
}

class IncomingReserveRequest {
  final int id;
  final String reserverName;
  final String reserverRole;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? status;
  final String? reason;
  final List<int>? cvIds;

  IncomingReserveRequest({
    required this.id,
    required this.reserverName,
    required this.reserverRole,
    required this.createdAt,
    required this.updatedAt,
    this.status,
    this.reason,
    this.cvIds,
  });

  factory IncomingReserveRequest.fromJson(Map<String, dynamic> json) {
    return IncomingReserveRequest(
      id: json['id'] ?? 0,
      reserverName: json['reserver'] != null
          ? '${json['reserver']['first_name'] ?? ''} ${json['reserver']['last_name'] ?? ''}'
              .trim()
          : 'Unknown',
      reserverRole: json['reserver']?['role'] ?? 'Unknown',
      createdAt:
          DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt:
          DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
      status: json['status'],
      reason: json['reason'],
      cvIds: json['cv_ids'] != null ? List<int>.from(json['cv_ids']) : null,
    );
  }
}

class ReserveDetail {
  final int id;
  final int cvId;
  final Map<String, dynamic> cv;
  final String? reason;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReserveDetail({
    required this.id,
    required this.cvId,
    required this.cv,
    this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReserveDetail.fromJson(Map<String, dynamic> json) {
    return ReserveDetail(
      id: json['id'] ?? 0,
      cvId: json['cv_id'] ?? 0,
      cv: Map<String, dynamic>.from(json['cv'] ?? {}),
      reason: json['reason'],
      status: json['status'] ?? 'pending',
      createdAt:
          DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt:
          DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
    );
  }

  String get employeeName {
    return cv['english_full_name'] ??
        cv['arabic_full_name'] ??
        cv['amharic_full_name'] ??
        'Unknown Employee';
  }

  String get occupation {
    return cv['occupation'] ?? 'No occupation specified';
  }
}
