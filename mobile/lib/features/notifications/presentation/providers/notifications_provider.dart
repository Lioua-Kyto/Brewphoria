import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:coffee_card/features/notifications/data/notification_remote_datasource.dart';
import 'package:coffee_card/features/notifications/domain/notification_model.dart';

part 'notifications_provider.g.dart';

@riverpod
NotificationRemoteDatasource notificationDataSource(Ref ref) =>
    NotificationRemoteDatasource();

@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  AsyncValue<List<NotificationModel>> build() {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        final result =
            await ref.read(notificationDataSourceProvider).getNotifications();
        return result.notifications;
      },
    );
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationDataSourceProvider).markRead(id);
    state = AsyncValue.data(
      state.valueOrNull
              ?.map((n) => n.id == id ? n.copyWith(isRead: true) : n)
              .toList() ??
          [],
    );
  }

  Future<void> markAllRead() async {
    await ref.read(notificationDataSourceProvider).markAllRead();
    state = AsyncValue.data(
      state.valueOrNull?.map((n) => n.copyWith(isRead: true)).toList() ?? [],
    );
  }

  Future<void> refresh() => _load();
}
