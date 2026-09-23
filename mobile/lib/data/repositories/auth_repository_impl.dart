import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepositoryImpl(remoteDataSource, tokenStorage);
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
    String? expectedRole,
  }) async {
    final response = await _remoteDataSource.login(
      email: email,
      password: password,
      expectedRole: expectedRole,
    );
    await _tokenStorage.saveToken(response.token);
    await _tokenStorage.saveUserRole(response.user.role.name);
    return response.user;
  }

  @override
  Future<UserEntity> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? addressLine1,
    String? pincode,
  }) async {
    final response = await _remoteDataSource.registerCustomer(
      name: name,
      email: email,
      phone: phone,
      password: password,
      addressLine1: addressLine1,
      pincode: pincode,
    );
    await _tokenStorage.saveToken(response.token);
    await _tokenStorage.saveUserRole(response.user.role.name);
    return response.user;
  }

  @override
  Future<UserEntity> registerTechnician({
    required String name,
    required String email,
    required String phone,
    required String password,
    required int experienceYears,
    required double visitingCharge,
    String? bio,
    String? pincode,
  }) async {
    final response = await _remoteDataSource.registerTechnician(
      name: name,
      email: email,
      phone: phone,
      password: password,
      experienceYears: experienceYears,
      visitingCharge: visitingCharge,
      bio: bio,
      pincode: pincode,
    );
    await _tokenStorage.saveToken(response.token);
    await _tokenStorage.saveUserRole(response.user.role.name);
    return response.user;
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Even if network fails, ensure local token is cleared
    } finally {
      await _tokenStorage.clear();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    try {
      return await _remoteDataSource.getMe();
    } catch (_) {
      await _tokenStorage.clear();
      return null;
    }
  }
}