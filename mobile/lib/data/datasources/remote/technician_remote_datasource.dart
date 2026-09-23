import 'package:dio/dio.dart';
import '../../models/technician/technician_profile_model.dart';
import '../../models/technician/technician_verification_model.dart';

abstract class TechnicianRemoteDatasource {
  Future<TechnicianProfileModel> getProfile();
  Future<TechnicianProfileModel> updateProfile(Map<String, dynamic> data);
  Future<bool> toggleAvailability(bool isAvailable);
  Future<List<TechnicianVerificationModel>> getVerifications();
  Future<TechnicianVerificationModel> uploadVerificationDoc({
    required String documentType,
    String? documentNumber,
    required String filePath,
    required String fileName,
  });
}

class TechnicianRemoteDatasourceImpl implements TechnicianRemoteDatasource {
  final Dio _dio;

  TechnicianRemoteDatasourceImpl(this._dio);

  @override
  Future<TechnicianProfileModel> getProfile() async {
    final response = await _dio.get('/technician/profile');
    final data = response.data['data'] as Map<String, dynamic>;
    return TechnicianProfileModel.fromJson(data);
  }

  @override
  Future<TechnicianProfileModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/technician/profile', data: data);
    final responseData = response.data['data'] as Map<String, dynamic>;
    return TechnicianProfileModel.fromJson(responseData);
  }

  @override
  Future<bool> toggleAvailability(bool isAvailable) async {
    final response = await _dio.post(
      '/technician/availability',
      data: {'is_available': isAvailable},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return data['is_available'] as bool? ?? false;
  }

  @override
  Future<List<TechnicianVerificationModel>> getVerifications() async {
    final response = await _dio.get('/technician/verifications');
    final data = response.data['data'] as Map<String, dynamic>;
    final docs = data['documents'] as List<dynamic>;
    return docs.map((d) => TechnicianVerificationModel.fromJson(d as Map<String, dynamic>)).toList();
  }

  @override
  Future<TechnicianVerificationModel> uploadVerificationDoc({
    required String documentType,
    String? documentNumber,
    required String filePath,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'document_type': documentType,
      if (documentNumber != null && documentNumber.isNotEmpty) 'document_number': documentNumber,
      'document': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _dio.post('/technician/verifications', data: formData);
    final data = response.data['data'] as Map<String, dynamic>;
    return TechnicianVerificationModel.fromJson(data['verification'] as Map<String, dynamic>);
  }
}
