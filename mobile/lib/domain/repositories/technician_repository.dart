import '../entities/technician_profile_entity.dart';
import '../entities/technician_verification_entity.dart';

abstract class TechnicianRepository {
  Future<TechnicianProfileEntity> getProfile();
  Future<TechnicianProfileEntity> updateProfile({
    String? name,
    String? phone,
    String? bio,
    int? experienceYears,
    double? visitingCharge,
    String? cityId,
    String? address,
    String? pincode,
  });
  Future<bool> toggleAvailability(bool isAvailable);
  Future<List<TechnicianVerificationEntity>> getVerifications();
  Future<TechnicianVerificationEntity> uploadVerificationDoc({
    required String documentType,
    String? documentNumber,
    required String filePath,
    required String fileName,
  });
}
