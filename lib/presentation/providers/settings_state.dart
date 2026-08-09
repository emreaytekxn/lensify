import 'package:flutter/material.dart';

class SettingsState {
  final bool isGridView;
  final ThemeMode themeMode;
  final bool requireBiometricsOnStartup;
  final Locale locale;
  final bool showArchivesInHome;

  SettingsState({
    this.isGridView = true,
    this.themeMode = ThemeMode.system,
    this.requireBiometricsOnStartup = false,
    this.locale = const Locale('en'),
    this.showArchivesInHome = true,
  });

  SettingsState copyWith({
    bool? isGridView,
    ThemeMode? themeMode,
    bool? requireBiometricsOnStartup,
    Locale? locale,
    bool? showArchivesInHome,
  }) {
    return SettingsState(
      isGridView: isGridView ?? this.isGridView,
      themeMode: themeMode ?? this.themeMode,
      requireBiometricsOnStartup:
          requireBiometricsOnStartup ?? this.requireBiometricsOnStartup,
      locale: locale ?? this.locale,
      showArchivesInHome: showArchivesInHome ?? this.showArchivesInHome,
    );
  }
}
