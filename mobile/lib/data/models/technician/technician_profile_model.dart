import '../../../domain/entities/technician_profile_entity.dart';

class TechnicianProfileModel extends TechnicianProfileEntity {
  const TechnicianProfileModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    required super.phone,
    super.bio,
    required super.experienceYears,
    required super.visitingCharge,
    required super.verificationStatus,
    super.verificationNotes,
    required super.isAvailable,
    super.cityId,
    super.cityName,
    super.ratingAvg,
    super.ratingCount,
    super.totalCompletedServices,
  });

  factory TechnicianProfileModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>? ?? {};
    final techMap = json['technician'] as Map<String, dynamic>? ?? {};
    final cityMap = techMap['city'] as Map<String, dynamic>?;

    return TechnicianProfileModel(
      id: techMap['id'] as String? ?? userMap['id'] as String? ?? '',
      userId: userMap['id'] as String? ?? '',
      name: userMap['name'] as String? ?? '',
      email: userMap['email'] as String? ?? '',
      phone: userMap['phone'] as String? ?? '',
      bio: techMap['bio'] as String?,
      experienceYears: (techMap['experience_years'] as num?)?.toInt() ?? 0,
      visitingCharge: double.tryParse(techMap['visiting_charge']?.toString() ?? '0') ?? 0.0,
      verificationStatus: techMap['verification_status'] as String? ?? 'pending',
      verificationNotes: techMap['verification_notes'] as String?,
      isAvailable: techMap['is_available'] as bool? ?? false,
      cityId: techMap['city_id'] as String?,
      cityName: cityMap?['name'] as String?,
      ratingAvg: double.tryParse(techMap['rating_avg']?.toString() ?? '0') ?? 0.0,
      ratingCount: (techMap['rating_count'] as num?)?.toInt() ?? 0,
      totalCompletedServices: (techMap['total_completed_services'] as num?)?.toInt() ?? 0,
    );
  }
}
