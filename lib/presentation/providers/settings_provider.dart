import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_state.dart';

import '../../main.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final themeIndex = prefs.getInt('themeMode');
    final langCode = prefs.getString('languageCode');

    ThemeMode savedTheme = ThemeMode.system;
    if (themeIndex != null) {
      savedTheme = ThemeMode.values[themeIndex];
    }

    Locale savedLocale = const Locale('tr');
    if (langCode != null) {
      savedLocale = Locale(langCode);
    }

    state = state.copyWith(themeMode: savedTheme, locale: savedLocale);
  }

  void toggleViewMode() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  void setThemeMode(ThemeMode mode) {
    prefs.setInt('themeMode', mode.index);
    state = state.copyWith(themeMode: mode);
  }

  void setLocale(Locale locale) {
    prefs.setString('languageCode', locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  void toggleTheme() {
    if (state.themeMode == ThemeMode.dark) {
      state = state.copyWith(themeMode: ThemeMode.light);
    } else if (state.themeMode == ThemeMode.light) {
      state = state.copyWith(themeMode: ThemeMode.dark);
    } else {
      // If system, just force dark for now (or base on platform brightness in a real UI check)
      state = state.copyWith(themeMode: ThemeMode.dark);
    }
  }

  void toggleBiometricsOnStartup() {
    state = state.copyWith(
        requireBiometricsOnStartup: !state.requireBiometricsOnStartup);
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
