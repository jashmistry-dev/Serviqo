import '../../../domain/entities/technician_verification_entity.dart';

class TechnicianVerificationModel extends TechnicianVerificationEntity {
  const TechnicianVerificationModel({
    required super.id,
    required super.documentType,
    super.documentNumber,
    required super.filePath,
    required super.status,
    super.rejectionReason,
    super.reviewedAt,
    required super.createdAt,
  });

  factory TechnicianVerificationModel.fromJson(Map<String, dynamic> json) {
    return TechnicianVerificationModel(
      id: json['id'] as String,
      documentType: json['document_type'] as String,
      documentNumber: json['document_number'] as String?,
      filePath: json['file_path'] as String,
      status: json['status'] as String? ?? 'pending',
      rejectionReason: json['rejection_reason'] as String?,
      reviewedAt: json['reviewed_at'] != null ? DateTime.tryParse(json['reviewed_at'] as String) : null,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}
