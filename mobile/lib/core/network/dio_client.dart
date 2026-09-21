import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';

/// Riverpod provider exposing a configured [Dio] HTTP client.
/// Auth interceptors and error handling will be added in Step 3.
final dioClientProvider = Provider<Dio>((ref) {
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

  // Auth and error interceptors will be added in Step 3.
  return dio;
});
