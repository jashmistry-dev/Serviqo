import 'package:flutter/foundation.dart';

/// Serviqo API endpoint constants.
class ApiConstants {
  ApiConstants._();

  /// Dynamically resolves base URL depending on platform.
  /// Web -> 127.0.0.1:8080/api
  /// Android Emulator -> 10.0.2.2:8080/api
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8080/api';
    }
    return 'http://10.0.2.2:8080/api';
  }

  // Auth endpoints
  static const String login = '/auth/login';
  static const String registerCustomer = '/auth/register/customer';
  static const String registerTechnician = '/auth/register/technician';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Timeouts
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 30000;
}