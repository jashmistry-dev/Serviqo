import 'package:equatable/equatable.dart';

class TechnicianProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String? bio;
  final int experienceYears;
  final double visitingCharge;
  final String verificationStatus; // pending, under_review, verified, rejected, suspended
  final String? verificationNotes;
  final bool isAvailable;
  final String? cityId;
  final String? cityName;
  final double ratingAvg;
  final int ratingCount;
  final int totalCompletedServices;

  const TechnicianProfileEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.bio,
    required this.experienceYears,
    required this.visitingCharge,
    required this.verificationStatus,
    this.verificationNotes,
    required this.isAvailable,
    this.cityId,
    this.cityName,
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    this.totalCompletedServices = 0,
  });

  bool get isVerified => verificationStatus == 'verified';

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        email,
        phone,
        bio,
        experienceYears,
        visitingCharge,
        verificationStatus,
        verificationNotes,
        isAvailable,
        cityId,
        cityName,
        ratingAvg,
        ratingCount,
        totalCompletedServices,
      ];
}
