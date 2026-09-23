import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/auth_repository_impl.dart';
import '../../../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthInitial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = const Unauthenticated();
      }
    } catch (_) {
      state = const Unauthenticated();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    String? expectedRole,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
        expectedRole: expectedRole,
      );
      state = Authenticated(user);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] as String? ?? 'Login failed.')
          : 'Network error occurred. Please check connection.';
      state = AuthError(msg);
      return false;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? addressLine1,
    String? pincode,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.registerCustomer(
        name: name,
        email: email,
        phone: phone,
        password: password,
        addressLine1: addressLine1,
        pincode: pincode,
      );
      state = Authenticated(user);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] as String? ?? 'Registration failed.')
          : 'Network error occurred. Please check connection.';
      state = AuthError(msg);
      return false;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> registerTechnician({
    required String name,
    required String email,
    required String phone,
    required String password,
    required int experienceYears,
    required double visitingCharge,
    String? bio,
    String? pincode,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.registerTechnician(
        name: name,
        email: email,
        phone: phone,
        password: password,
        experienceYears: experienceYears,
        visitingCharge: visitingCharge,
        bio: bio,
        pincode: pincode,
      );
      state = Authenticated(user);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] as String? ?? 'Registration failed.')
          : 'Network error occurred. Please check connection.';
      state = AuthError(msg);
      return false;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthLoading();
    await _authRepository.logout();
    state = const Unauthenticated();
  }
}