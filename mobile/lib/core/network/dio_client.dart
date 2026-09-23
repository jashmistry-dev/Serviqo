import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../storage/token_storage.dart';

/// Riverpod provider exposing a configured [Dio] HTTP client
/// with automatic token injection and 401 handling.
final dioClientProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-App-Name': AppConstants.appName,
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await tokenStorage.clear();
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});