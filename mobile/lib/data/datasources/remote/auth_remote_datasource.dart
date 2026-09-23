import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/user/user_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AuthRemoteDataSource(dio);
});

class AuthResponse {
  final UserModel user;
  final String token;
  final Map<String, dynamic>? profile;
  final String message;

  AuthResponse({
    required this.user,
    required this.token,
    this.profile,
    required this.message,
  });
}

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<AuthResponse> login({
    required String email,
    required String password,
    String? expectedRole,
  }) async {
    final payload = <String, dynamic>{
      'email': email,
      'password': password,
    };
    if (expectedRole != null) {
      payload['expected_role'] = expectedRole;
    }

    final response = await _dio.post(
      ApiConstants.login,
      data: payload,
    );

    final data = response.data as Map<String, dynamic>;
    return AuthResponse(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
      profile: data['profile'] as Map<String, dynamic>?,
      message: data['message'] as String? ?? 'Login successful',
    );
  }

  Future<AuthResponse> registerCustomer({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? addressLine1,
    String? pincode,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };
    if (addressLine1 != null) payload['address_line1'] = addressLine1;
    if (pincode != null) payload['pincode'] = pincode;

    final response = await _dio.post(
      ApiConstants.registerCustomer,
      data: payload,
    );

    final data = response.data as Map<String, dynamic>;
    return AuthResponse(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
      profile: data['profile'] as Map<String, dynamic>?,
      message: data['message'] as String? ?? 'Registration successful',
    );
  }

  Future<AuthResponse> registerTechnician({
    required String name,
    required String email,
    required String phone,
    required String password,
    required int experienceYears,
    required double visitingCharge,
    String? bio,
    String? pincode,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'experience_years': experienceYears,
      'visiting_charge': visitingCharge,
    };
    if (bio != null) payload['bio'] = bio;
    if (pincode != null) payload['pincode'] = pincode;

    final response = await _dio.post(
      ApiConstants.registerTechnician,
      data: payload,
    );

    final data = response.data as Map<String, dynamic>;
    return AuthResponse(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
      profile: data['profile'] as Map<String, dynamic>?,
      message: data['message'] as String? ?? 'Registration successful',
    );
  }

  Future<void> logout() async {
    await _dio.post(ApiConstants.logout);
  }

  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiConstants.me);
    final data = response.data as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}