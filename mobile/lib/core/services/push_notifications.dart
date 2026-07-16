import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:brewphoria/firebase_options.dart';
import 'package:brewphoria/core/router/app_router.dart';
import 'package:brewphoria/core/router/route_names.dart';
import 'package:brewphoria/features/auth/presentation/providers/auth_provider.dart';

/// Attached to [MaterialApp] so the service can surface foreground messages
/// without needing a screen's BuildContext.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Background / terminated handler. Must be a top-level function. Android
/// auto-displays notification-payload messages in the system tray while the app
/// is backgrounded, so there's nothing to render here — we just make sure
/// Firebase is available for any future data-only handling.
@pragma('vm:entry-point')
Future<void> pushBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// Wires Firebase Cloud Messaging into the app: permission, token registration,
/// foreground display, and deep-linking on notification taps.
class PushNotifications {
  PushNotifications(this.ref);

  final WidgetRef ref;
  final _fm = FirebaseMessaging.instance;

  Future<void> init() async {
    await _fm.requestPermission(alert: true, badge: true, sound: true);
    await _fm.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);

    // App opened from a terminated state by tapping a notification.
    final initial = await _fm.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _onOpened(initial));
    }

    _fm.onTokenRefresh.listen(_sendToken);
  }

  /// Fetch the device token and register it with the backend. Call once the
  /// user is authenticated (the endpoint is auth-gated).
  Future<void> registerToken() async {
    try {
      final token = await _fm.getToken();
      if (token != null) await _sendToken(token);
    } catch (_) {
      // Non-fatal — push simply won't reach this device until next launch.
    }
  }

  Future<void> _sendToken(String token) =>
      ref.read(authNotifierProvider.notifier).updateFcmToken(token);

  void _onForeground(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    final text = (n.title == null || n.title!.isEmpty)
        ? (n.body ?? '')
        : '${n.title}${n.body == null ? '' : ' · ${n.body}'}';
    scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(text),
          action: SnackBarAction(
              label: 'View', onPressed: () => _route(message.data)),
        ),
      );
  }

  void _onOpened(RemoteMessage message) => _route(message.data);

  /// Deep-link based on the notification's `data.type` payload.
  void _route(Map<String, dynamic> data) {
    final router = ref.read(appRouterProvider);
    final type = data['type'] as String?;
    final orderId = data['orderId'] as String?;

    switch (type) {
      case 'REVIEW_REQUEST':
        if (orderId != null && orderId.isNotEmpty) {
          router.pushNamed(RouteNames.writeReview,
              pathParameters: {'orderId': orderId});
          return;
        }
      case 'ORDER_STATUS_CHANGED':
        if (orderId != null && orderId.isNotEmpty) {
          router.pushNamed(RouteNames.orderDetail,
              pathParameters: {'id': orderId});
          return;
        }
    }
    router.pushNamed(RouteNames.notifications);
  }
}
