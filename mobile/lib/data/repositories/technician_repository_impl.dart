import '../../domain/entities/technician_profile_entity.dart';
import '../../domain/entities/technician_verification_entity.dart';
import '../../domain/repositories/technician_repository.dart';
import '../datasources/remote/technician_remote_datasource.dart';

class TechnicianRepositoryImpl implements TechnicianRepository {
  final TechnicianRemoteDatasource _remoteDatasource;

  TechnicianRepositoryImpl(this._remoteDatasource);

  @override
  Future<TechnicianProfileEntity> getProfile() {
    return _remoteDatasource.getProfile();
  }

  @override
  Future<TechnicianProfileEntity> updateProfile({
    String? name,
    String? phone,
    String? bio,
    int? experienceYears,
    double? visitingCharge,
    String? cityId,
    String? address,
    String? pincode,
  }) {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (bio != null) data['bio'] = bio;
    if (experienceYears != null) data['experience_years'] = experienceYears;
    if (visitingCharge != null) data['visiting_charge'] = visitingCharge;
    if (cityId != null) data['city_id'] = cityId;
    if (address != null) data['address'] = address;
    if (pincode != null) data['pincode'] = pincode;

    return _remoteDatasource.updateProfile(data);
  }

  @override
  Future<bool> toggleAvailability(bool isAvailable) {
    return _remoteDatasource.toggleAvailability(isAvailable);
  }

  @override
  Future<List<TechnicianVerificationEntity>> getVerifications() {
    return _remoteDatasource.getVerifications();
  }

  @override
  Future<TechnicianVerificationEntity> uploadVerificationDoc({
    required String documentType,
    String? documentNumber,
    required String filePath,
    required String fileName,
  }) {
    return _remoteDatasource.uploadVerificationDoc(
      documentType: documentType,
      documentNumber: documentNumber,
      filePath: filePath,
      fileName: fileName,
    );
  }
}
