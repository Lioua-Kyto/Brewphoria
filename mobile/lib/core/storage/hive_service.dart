import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

abstract final class HiveBoxes {
  static const String cart = 'cart_box';
  static const String userPrefs = 'user_prefs_box';
}

abstract final class HiveKeys {
  static const String cartItems = 'cart_items';
  static const String theme = 'theme_mode';
  static const String tipPercent = 'cart_tip_percent';
  static const String onboardingDone = 'onboarding_done';
  static const String guestMode = 'guest_mode';

  /// Set while the local cart holds guest-authored lines that still need to be
  /// merged into the account cart on the next sign-in.
  static const String guestCartPending = 'guest_cart_pending';
}

class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<dynamic>(HiveBoxes.cart),
      Hive.openBox<dynamic>(HiveBoxes.userPrefs),
    ]);
    debugPrint('[HiveService] Boxes opened.');
  }

  static Box<dynamic> get cartBox => Hive.box<dynamic>(HiveBoxes.cart);
  static Box<dynamic> get userPrefsBox => Hive.box<dynamic>(HiveBoxes.userPrefs);

  static Future<void> clearCart() async {
    await cartBox.clear();
  }

  static Future<void> closeAll() async {
    await Hive.close();
  }
}
