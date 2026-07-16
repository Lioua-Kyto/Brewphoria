import 'package:dio/dio.dart';
import 'package:brewphoria/core/constants/api_endpoints.dart';
import 'package:brewphoria/core/network/dio_client.dart';
import 'package:brewphoria/features/auth/domain/user_model.dart';

class AuthRemoteDatasource {
  final Dio _dio = DioClient.instance.dio;

  Future<LoginResponse> login(String idToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'idToken': idToken},
      );
      return LoginResponse.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post<void>(ApiEndpoints.logout);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _dio.patch<void>(ApiEndpoints.fcmToken, data: {'fcmToken': fcmToken});
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
