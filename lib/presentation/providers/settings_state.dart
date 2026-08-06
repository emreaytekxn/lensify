import 'package:flutter/material.dart';

class SettingsState {
  final bool isGridView;
  final ThemeMode themeMode;
  final bool requireBiometricsOnStartup;

  SettingsState({
    this.isGridView = true,
    this.themeMode = ThemeMode.system,
    this.requireBiometricsOnStartup = false,
  });

  SettingsState copyWith({
    bool? isGridView,
    ThemeMode? themeMode,
    bool? requireBiometricsOnStartup,
  }) {
    return SettingsState(
      isGridView: isGridView ?? this.isGridView,
      themeMode: themeMode ?? this.themeMode,
      requireBiometricsOnStartup: requireBiometricsOnStartup ?? this.requireBiometricsOnStartup,
    );
  }
}
