import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._prefs) : super(ThemeMode.system) {
    _load();
  }

  final SharedPreferences _prefs;

  void _load() {
    final value = _prefs.getString(StorageKeys.themeMode);
    state = _fromStorage(value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(StorageKeys.themeMode, _toStorage(mode));
  }

  Future<void> toggleLightDark() async {
    if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
      return;
    }
    await setThemeMode(ThemeMode.dark);
  }

  Future<void> toggleFromSystem(Brightness platformBrightness) async {
    if (state != ThemeMode.system) {
      await toggleLightDark();
      return;
    }

    final next = platformBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(next);
  }

  static ThemeMode _fromStorage(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case null:
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  static String _toStorage(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
