import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:coffee_card/core/storage/hive_service.dart';

part 'guest_provider.g.dart';

/// Whether the user chose to browse without an account. Persisted so it
/// survives restarts. Cleared on sign-in / sign-out.
@riverpod
class GuestMode extends _$GuestMode {
  @override
  bool build() {
    try {
      return HiveService.userPrefsBox.get(HiveKeys.guestMode) == true;
    } catch (_) {
      return false;
    }
  }

  void set(bool value) {
    state = value;
    try {
      HiveService.userPrefsBox.put(HiveKeys.guestMode, value);
    } catch (_) {}
  }
}

/// Router-safe synchronous read (used inside the redirect, which can't watch
/// providers cheaply).
bool isGuestMode() {
  try {
    return HiveService.userPrefsBox.get(HiveKeys.guestMode) == true;
  } catch (_) {
    return false;
  }
}

void clearGuestMode() {
  try {
    HiveService.userPrefsBox.put(HiveKeys.guestMode, false);
  } catch (_) {}
}
