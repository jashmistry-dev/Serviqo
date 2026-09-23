import '../../../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.phone,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: _parseRole(json['role'] as String?),
    );
  }

  static UserRole _parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'technician':
        return UserRole.technician;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role.name,
    };
  }
}