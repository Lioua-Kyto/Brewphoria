import 'package:dio/dio.dart';
import 'package:brewphoria/core/constants/api_endpoints.dart';
import 'package:brewphoria/core/network/dio_client.dart';
import 'package:brewphoria/features/notifications/domain/notification_model.dart';

class NotificationsListResult {
  const NotificationsListResult({
    required this.notifications,
    required this.total,
    required this.totalPages,
    required this.page,
  });

  final List<NotificationModel> notifications;
  final int total;
  final int totalPages;
  final int page;
}

class NotificationRemoteDatasource {
  final Dio _dio = DioClient.instance.dio;

  Future<NotificationsListResult> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.notifications,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data!['data'] as List<dynamic>;
      final meta = response.data!['meta'] as Map<String, dynamic>?;
      return NotificationsListResult(
        notifications: data
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (meta?['total'] as int?) ?? 0,
        totalPages: (meta?['totalPages'] as int?) ?? 1,
        page: (meta?['page'] as int?) ?? 1,
      );
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<NotificationModel> markRead(String id) async {
    try {
      final response =
          await _dio.patch<Map<String, dynamic>>(ApiEndpoints.notificationRead(id));
      return NotificationModel.fromJson(response.data!['data'] as Map<String, dynamic>);
    } catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.patch<void>(ApiEndpoints.notificationsReadAll);
    } catch (e) {
      throw mapDioException(e);
    }
  }
}
