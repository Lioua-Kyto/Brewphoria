import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:brewphoria/core/config/app_config.dart';
import 'package:brewphoria/core/router/app_router.dart';
import 'package:brewphoria/core/services/push_notifications.dart';
import 'package:brewphoria/core/theme/app_theme.dart';
import 'package:brewphoria/core/theme/theme_mode_provider.dart';
import 'package:brewphoria/core/storage/hive_service.dart';
import 'package:brewphoria/core/widgets/brand_splash.dart';
import 'package:brewphoria/features/auth/presentation/providers/auth_provider.dart';
import 'package:brewphoria/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    // Push needs a live project + network — skip it entirely in offline demo.
    if (!AppConfig.useMockData) {
      FirebaseMessaging.onBackgroundMessage(pushBackgroundHandler);
    }
  } catch (e) {
    debugPrint('[Firebase] Init failed: $e. Run: flutterfire configure');
  }
  await HiveService.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: BrewPhoriaApp()));
}

class BrewPhoriaApp extends ConsumerStatefulWidget {
  const BrewPhoriaApp({super.key});

  @override
  ConsumerState<BrewPhoriaApp> createState() => _BrewPhoriaAppState();
}

class _BrewPhoriaAppState extends ConsumerState<BrewPhoriaApp> {
  late final PushNotifications _push = PushNotifications(ref);

  @override
  void initState() {
    super.initState();
    if (!AppConfig.useMockData) _push.init();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    // Register the FCM token with the backend once the user is authenticated.
    if (!AppConfig.useMockData) {
      ref.listen(authNotifierProvider, (prev, next) {
        final becameLoggedIn =
            (prev?.valueOrNull == null) && (next.valueOrNull != null);
        if (becameLoggedIn) _push.registerToken();
      });
    }

    return MaterialApp.router(
      title: 'BrewPhoria',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      themeMode: themeMode,
      builder: (context, child) => _SplashGate(child: child ?? const SizedBox()),
    );
  }
}

/// Overlays the [BrandSplash] on cold start, then fades it away to reveal the
/// routed app underneath.
class _SplashGate extends StatefulWidget {
  const _SplashGate({required this.child});
  final Widget child;

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (c, anim) => FadeTransition(opacity: anim, child: c),
          child: _showSplash
              ? BrandSplash(
                  onComplete: () => setState(() => _showSplash = false))
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
