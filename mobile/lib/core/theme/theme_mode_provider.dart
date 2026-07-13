import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:coffee_card/core/storage/hive_service.dart';

part 'theme_mode_provider.g.dart';

/// App theme mode, toggleable from Profile (brief §5.7). Persisted to Hive so
/// the choice survives restarts. Defaults to system.
@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() {
    try {
      final saved = HiveService.userPrefsBox.get(HiveKeys.theme) as String?;
      return switch (saved) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (_) {
      return ThemeMode.system;
    }
  }

  void setDark(bool dark) {
    state = dark ? ThemeMode.dark : ThemeMode.light;
    try {
      HiveService.userPrefsBox.put(HiveKeys.theme, dark ? 'dark' : 'light');
    } catch (_) {}
  }
}
