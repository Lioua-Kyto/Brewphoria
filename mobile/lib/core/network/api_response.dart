import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiMeta? meta;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool,
      data: json['data'] == null ? null : fromJsonT(json['data']!),
      message: json['message'] as String?,
      meta: json['meta'] == null
          ? null
          : ApiMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
    return {
      'success': success,
      if (data != null) 'data': toJsonT(data as T),
      if (message != null) 'message': message,
      if (meta != null) 'meta': meta!.toJson(),
    };
  }
}

@freezed
class ApiMeta with _$ApiMeta {
  const factory ApiMeta({
    required int page,
    required int limit,
    required int total,
    required int totalPages,
  }) = _ApiMeta;

  factory ApiMeta.fromJson(Map<String, dynamic> json) => _$ApiMetaFromJson(json);
}

@freezed
class ApiError with _$ApiError {
  const factory ApiError({
    required String code,
    required String message,
    Map<String, List<String>>? fields,
  }) = _ApiError;

  factory ApiError.fromJson(Map<String, dynamic> json) => _$ApiErrorFromJson(json);
}
