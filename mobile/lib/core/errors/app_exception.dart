sealed class AppException implements Exception {
  const AppException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection. Please check your network.'});
}

final class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Session expired. Please sign in again.'})
      : super(statusCode: 401);
}

final class ForbiddenException extends AppException {
  const ForbiddenException({super.message = 'You do not have permission to perform this action.'})
      : super(statusCode: 403);
}

final class NotFoundException extends AppException {
  const NotFoundException({super.message = 'The requested resource was not found.'})
      : super(statusCode: 404);
}

final class ValidationException extends AppException {
  const ValidationException({
    super.message = 'Invalid input. Please check your data.',
    this.fields,
  }) : super(statusCode: 422);

  final Map<String, List<String>>? fields;
}

final class ServerException extends AppException {
  const ServerException({super.message = 'Something went wrong. Please try again.'})
      : super(statusCode: 500);
}

final class CacheException extends AppException {
  const CacheException({super.message = 'Failed to load cached data.'});
}

final class ConflictException extends AppException {
  const ConflictException({super.message = 'This resource already exists.'})
      : super(statusCode: 409);
}

final class UnknownException extends AppException {
  const UnknownException({super.message = 'An unexpected error occurred.'});
}

/// Human-facing message for any thrown error: the typed [AppException] message
/// when available, otherwise the raw text with any "SomeException: " prefix
/// stripped so users never see `Exception:` noise.
String friendlyError(Object error) {
  if (error is AppException) return error.message;
  return error.toString().replaceFirst(RegExp(r'^[A-Za-z]*Exception:\s*'), '');
}
