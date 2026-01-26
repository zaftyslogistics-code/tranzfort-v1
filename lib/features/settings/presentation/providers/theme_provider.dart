import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode options for v0.02
enum AppThemeMode {
  system,  // Follow device (default)
  light,   // Force light mode
  dark,    // Force dark mode
}

/// Theme state
class ThemeState {
  final AppThemeMode themeMode;
  final bool isLoading;

  const ThemeState({
    this.themeMode = AppThemeMode.system,
    this.isLoading = false,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Get Flutter ThemeMode from AppThemeMode
  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Theme notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeKey = 'app_theme_mode';
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs) : super(const ThemeState()) {
    _loadTheme();
  }

  /// Load saved theme preference
  Future<void> _loadTheme() async {
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      final themeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.name == savedTheme,
        orElse: () => AppThemeMode.system,
      );
      state = state.copyWith(themeMode: themeMode);
    }
  }

  /// Set theme mode and persist
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(isLoading: true);
    await _prefs.setString(_themeKey, mode.name);
    state = state.copyWith(
      themeMode: mode,
      isLoading: false,
    );
  }

  /// Toggle between light and dark (for quick toggle)
  Future<void> toggleTheme(Brightness currentBrightness) async {
    final newMode = currentBrightness == Brightness.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    await setThemeMode(newMode);
  }
}

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  // This will be overridden in main.dart with actual SharedPreferences
  throw UnimplementedError('themeProvider must be overridden');
});
