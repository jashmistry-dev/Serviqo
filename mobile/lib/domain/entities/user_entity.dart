import 'package:equatable/equatable.dart';

enum UserRole { customer, technician, admin }

/// Core domain entity for an authenticated user.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? avatarUrl;

  bool get isCustomer => role == UserRole.customer;
  bool get isTechnician => role == UserRole.technician;
  bool get isAdmin => role == UserRole.admin;

  @override
  List<Object?> get props => [id, name, email, role, phone, avatarUrl];
}