/// Serviqo API endpoint constants.
/// Update baseUrl to match your development environment:
///   - Android emulator: `http://10.0.2.2:8080/api`
///   - Physical device (same WiFi): `http://YOUR_LAN_IP:8080/api`
class ApiConstants {
  ApiConstants._();

  /// Development default — Android emulator accesses host via 10.0.2.2
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  // For physical device on same WiFi, replace with your LAN IP:
  // static const String baseUrl = 'http://192.168.x.x:8080/api';

  // Timeouts
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 30000;
}
