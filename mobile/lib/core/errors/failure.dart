import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.network({
    @Default('No internet connection.') String message,
  }) = NetworkFailure;

  const factory Failure.unauthorized({
    @Default('Session expired. Please sign in again.') String message,
  }) = UnauthorizedFailure;

  const factory Failure.forbidden({
    @Default('Permission denied.') String message,
  }) = ForbiddenFailure;

  const factory Failure.notFound({
    @Default('Resource not found.') String message,
  }) = NotFoundFailure;

  const factory Failure.validation({
    @Default('Invalid input.') String message,
    Map<String, List<String>>? fields,
  }) = ValidationFailure;

  const factory Failure.server({
    @Default('Server error. Please try again.') String message,
  }) = ServerFailure;

  const factory Failure.cache({
    @Default('Failed to load cached data.') String message,
  }) = CacheFailure;

  const factory Failure.unknown({
    @Default('An unexpected error occurred.') String message,
  }) = UnknownFailure;
}
