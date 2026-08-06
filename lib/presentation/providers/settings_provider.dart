import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_state.dart';

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());

  void toggleViewMode() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
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
    state = state.copyWith(requireBiometricsOnStartup: !state.requireBiometricsOnStartup);
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
