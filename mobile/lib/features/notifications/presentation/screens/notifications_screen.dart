import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brewphoria/core/constants/app_colors.dart';
import 'package:brewphoria/core/constants/app_text_styles.dart';
import 'package:brewphoria/core/errors/app_exception.dart';
import 'package:brewphoria/core/widgets/app_error_widget.dart';
import 'package:brewphoria/core/utils/extensions.dart';
import 'package:brewphoria/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:brewphoria/features/notifications/domain/notification_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsNotifierProvider);
    final hasUnread = notificationsAsync.valueOrNull
            ?.any((n) => !n.isRead) ??
        false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.headlineMedium),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsNotifierProvider.notifier).markAllRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) => notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_off_outlined,
                        size: 80, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    Text('No notifications',
                        style: AppTextStyles.headlineSmall
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(notificationsNotifierProvider.notifier).refresh(),
                child: ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) =>
                      _NotificationTile(notification: notifications[i]),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorWidget(
          message: friendlyError(e),
          onRetry: () =>
              ref.read(notificationsNotifierProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () {
        if (!notification.isRead) {
          ref
              .read(notificationsNotifierProvider.notifier)
              .markRead(notification.id);
        }
      },
      tileColor: notification.isRead
          ? null
          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
      leading: CircleAvatar(
        backgroundColor: _iconColor.withValues(alpha: 0.15),
        child: Icon(_icon, color: _iconColor, size: 22),
      ),
      title: Text(
        notification.title,
        style: AppTextStyles.labelLarge.copyWith(
          fontWeight:
              notification.isRead ? FontWeight.w400 : FontWeight.w700,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(notification.body, style: AppTextStyles.bodySmall),
          const SizedBox(height: 2),
          Text(
            notification.createdAt.toRelative,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
      trailing: !notification.isRead
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
      isThreeLine: true,
    );
  }

  IconData get _icon => switch (notification.type) {
        'ORDER_STATUS_CHANGED' => Icons.local_shipping_outlined,
        'NEW_SALE' => Icons.local_offer_outlined,
        'LOYALTY_TIER_UP' => Icons.star,
        'POINTS_EXPIRING' => Icons.warning_amber_outlined,
        'NEW_ORDER' => Icons.shopping_cart_outlined,
        'NEW_REVIEW' => Icons.rate_review_outlined,
        _ => Icons.notifications_outlined,
      };

  Color get _iconColor => switch (notification.type) {
        'ORDER_STATUS_CHANGED' => AppColors.statusConfirmed,
        'NEW_SALE' => AppColors.secondary,
        'LOYALTY_TIER_UP' => AppColors.tierGold,
        'POINTS_EXPIRING' => AppColors.statusPending,
        _ => AppColors.primary,
      };
}
