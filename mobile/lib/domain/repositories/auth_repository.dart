import '../entities/user_entity.dart';

/// Abstract contract for authentication operations.
/// Concrete implementation lives in data/repositories/.
abstract interface class AuthRepository {
  /// Log in with email and password.
  /// Returns the authenticated [UserEntity] on success.
  Future<UserEntity> login({required String email, required String password});

  /// Log out the currently authenticated user.
  Future<void> logout();

  /// Get the currently stored authenticated user, or null if not logged in.
  Future<UserEntity?> getCurrentUser();
}
