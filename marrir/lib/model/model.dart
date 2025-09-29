class UnreservedEmployee {
  final int? id;
  final String? englishFullName;
  final String? arabicFullName;
  final String? amharicFullName;
  final String? occupation;
  final String? sex;
  final int? height;
  final int? weight;
  final String? skinTone;
  final String? dateOfBirth;
  final String? phoneNumber;
  final String? email;
  final String? summary;
  final String? nationality;
  final String? religion;
  final String? maritalStatus;
  final Map<String, dynamic>? promoter;
  final Map<String, dynamic>? cv;

  UnreservedEmployee({
    this.id,
    this.englishFullName,
    this.arabicFullName,
    this.amharicFullName,
    this.occupation,
    this.sex,
    this.height,
    this.weight,
    this.skinTone,
    this.dateOfBirth,
    this.phoneNumber,
    this.email,
    this.summary,
    this.nationality,
    this.religion,
    this.maritalStatus,
    this.promoter,
    this.cv,
  });

  factory UnreservedEmployee.fromJson(Map<String, dynamic> json) {
    return UnreservedEmployee(
      id: json['id'],
      englishFullName:
          json['english_full_name'] ?? json['cv']?['english_full_name'],
      arabicFullName:
          json['arabic_full_name'] ?? json['cv']?['arabic_full_name'],
      amharicFullName:
          json['amharic_full_name'] ?? json['cv']?['amharic_full_name'],
      occupation: json['occupation'] ?? json['cv']?['occupation'],
      sex: json['sex'] ?? json['cv']?['sex'],
      height: json['height'] ?? json['cv']?['height'],
      weight: json['weight'] ?? json['cv']?['weight'],
      skinTone: json['skin_tone'] ?? json['cv']?['skin_tone'],
      dateOfBirth: json['date_of_birth'] ?? json['cv']?['date_of_birth'],
      phoneNumber: json['phone_number'] ?? json['cv']?['phone_number'],
      email: json['email'] ?? json['cv']?['email'],
      summary: json['summary'] ?? json['cv']?['summary'],
      nationality: json['nationality'] ?? json['cv']?['nationality'],
      religion: json['religion'] ?? json['cv']?['religion'],
      maritalStatus: json['marital_status'] ?? json['cv']?['marital_status'],
      promoter: json['promoter'] is Map
          ? Map<String, dynamic>.from(json['promoter'])
          : null,
      cv: json['cv'] is Map ? Map<String, dynamic>.from(json['cv']) : null,
    );
  }

  String get displayName {
    return englishFullName ?? arabicFullName ?? amharicFullName ?? 'Unknown';
  }

  String get displayOccupation {
    return occupation ?? 'No occupation specified';
  }

  String get experienceInfo {
    // You can calculate experience from date_of_birth or other fields
    return 'Experience information'; // Customize based on your data
  }
}

class ReserveCVFilter {
  final String? sex;
  final String? skinTone;
  final String? maritalStatus;
  final String? religion;
  final List<String>? nationality;
  final List<String>? occupation;
  final String? educationLevel;
  final int? minHeight;
  final int? maxHeight;
  final int? minWeight;
  final int? maxWeight;
  final int? minAge;
  final int? maxAge;

  ReserveCVFilter({
    this.sex,
    this.skinTone,
    this.maritalStatus,
    this.religion,
    this.nationality,
    this.occupation,
    this.educationLevel,
    this.minHeight,
    this.maxHeight,
    this.minWeight,
    this.maxWeight,
    this.minAge,
    this.maxAge,
  });

  Map<String, dynamic> toJson() {
    return {
      if (sex != null) 'sex': sex,
      if (skinTone != null) 'skin_tone': skinTone,
      if (maritalStatus != null) 'marital_status': maritalStatus,
      if (religion != null) 'religion': religion,
      if (nationality != null && nationality!.isNotEmpty)
        'nationality': nationality,
      if (occupation != null && occupation!.isNotEmpty)
        'occupation': occupation,
      if (educationLevel != null) 'education_level': educationLevel,
      if (minHeight != null) 'min_height': minHeight,
      if (maxHeight != null) 'max_height': maxHeight,
      if (minWeight != null) 'min_weight': minWeight,
      if (maxWeight != null) 'max_weight': maxWeight,
      if (minAge != null) 'min_age': minAge,
      if (maxAge != null) 'max_age': maxAge,
    };
  }
}
