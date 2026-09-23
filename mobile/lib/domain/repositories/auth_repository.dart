import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Future<UserEntity> login({
    required String email,
    required String password,
    String? expectedRole,
  });

  Future<UserEntity> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? addressLine1,
    String? pincode,
  });

  Future<UserEntity> registerTechnician({
    required String name,
    required String email,
    required String phone,
    required String password,
    required int experienceYears,
    required double visitingCharge,
    String? bio,
    String? pincode,
  });

  Future<void> logout();

  Future<UserEntity?> getCurrentUser();
}