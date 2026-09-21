/// Base exception for all Serviqo application errors.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Network or server communication failure.
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error. Please check your connection.']);
}

/// HTTP response indicated a client or server error.
class ServerException extends AppException {
  const ServerException({required this.statusCode, String? message})
      : super(message ?? 'Server error ($statusCode).');
  final int statusCode;
}

/// Authentication failed or token expired.
class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed. Please log in again.']);
}

/// Requested resource was not found.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found.']);
}

/// Input validation failed on the client side.
class ValidationException extends AppException {
  const ValidationException(super.message);
}
