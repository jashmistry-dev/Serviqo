import 'package:equatable/equatable.dart';

class TechnicianVerificationEntity extends Equatable {
  final String id;
  final String documentType;
  final String? documentNumber;
  final String filePath;
  final String status; // pending, approved, rejected
  final String? rejectionReason;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const TechnicianVerificationEntity({
    required this.id,
    required this.documentType,
    this.documentNumber,
    required this.filePath,
    required this.status,
    this.rejectionReason,
    this.reviewedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        documentType,
        documentNumber,
        filePath,
        status,
        rejectionReason,
        reviewedAt,
        createdAt,
      ];
}
