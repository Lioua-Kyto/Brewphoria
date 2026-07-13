import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:coffee_card/core/config/app_config.dart';
import 'package:coffee_card/core/constants/api_endpoints.dart';
import 'package:coffee_card/core/errors/app_exception.dart';
import 'package:coffee_card/core/network/mock_interceptor.dart';

class DioClient {
  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      // In offline demo mode this MUST be first — it resolves every request
      // locally before any network/auth work happens.
      if (AppConfig.useMockData) MockInterceptor(),
      _AuthInterceptor(),
      _ErrorInterceptor(),
      if (kDebugMode) _LoggingInterceptor(),
    ]);
  }

  static final DioClient _instance = DioClient._();
  static DioClient get instance => _instance;

  late final Dio _dio;
  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (e) {
      debugPrint('[AuthInterceptor] Failed to get token: $e');
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final alreadyRetried = err.requestOptions.extra['_retried'] == true;
    if (err.response?.statusCode == 401 && !alreadyRetried) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken(true);
          if (token != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $token';
            err.requestOptions.extra['_retried'] = true;
            final response = await DioClient.instance.dio.fetch(err.requestOptions);
            return handler.resolve(response);
          }
        }
      } catch (e) {
        debugPrint('[AuthInterceptor] Token refresh failed: $e');
      }
    }
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _mapError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
        response: err.response,
      ),
    );
  }

  AppException _mapError(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    final statusCode = err.response?.statusCode;
    final message = _extractMessage(err.response?.data);

    return switch (statusCode) {
      401 => UnauthorizedException(message: message ?? 'Session expired. Please sign in again.'),
      403 => ForbiddenException(message: message ?? 'Permission denied.'),
      404 => NotFoundException(message: message ?? 'Resource not found.'),
      409 => ConflictException(message: message ?? 'Resource already exists.'),
      422 => ValidationException(message: message ?? 'Invalid input.'),
      500 || 502 || 503 => ServerException(message: message ?? 'Server error. Please try again.'),
      _ => UnknownException(message: message ?? 'An unexpected error occurred.'),
    };
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['error']?['message'] as String? ?? data['message'] as String?;
    }
    return null;
  }
}

class _LoggingInterceptor extends Interceptor {
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _stopwatch.reset();
    _stopwatch.start();
    debugPrint('[HTTP] --> ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _stopwatch.stop();
    debugPrint(
      '[HTTP] <-- ${response.statusCode} ${response.requestOptions.uri} '
      '(${_stopwatch.elapsedMilliseconds}ms)',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _stopwatch.stop();
    debugPrint(
      '[HTTP] ERROR ${err.response?.statusCode} ${err.requestOptions.uri} '
      '(${_stopwatch.elapsedMilliseconds}ms): ${err.message}',
    );
    handler.next(err);
  }
}

AppException mapDioException(Object error) {
  if (error is DioException && error.error is AppException) {
    return error.error as AppException;
  }
  if (error is AppException) return error;
  return const UnknownException();
}
