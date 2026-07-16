import 'package:dio/dio.dart';
import 'package:brewphoria/core/mock/mock_backend.dart';

/// When offline demo mode is on, this is the FIRST Dio interceptor: it answers
/// every request from [MockBackend] and resolves it locally, so no network call
/// is ever made. The rest of the app (repositories, models, providers) is
/// untouched — it just sees normal API responses.
class MockInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // A little latency so skeletons/loaders still get their moment.
    await Future<void>.delayed(const Duration(milliseconds: 120));

    final path = options.path.replaceFirst(RegExp(r'^/api/v1'), '');
    final (status, body) = MockBackend.instance.handle(
      options.method.toUpperCase(),
      path,
      options.queryParameters,
      options.data,
    );

    final response = Response<dynamic>(
      requestOptions: options,
      statusCode: status,
      data: body,
    );

    if (status >= 400) {
      // `true` → let the following error interceptors map it to a typed
      // AppException, exactly as a real API error would be handled.
      handler.reject(
        DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        ),
        true,
      );
    } else {
      handler.resolve(response);
    }
  }
}
