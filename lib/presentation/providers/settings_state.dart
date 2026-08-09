import 'package:flutter/material.dart';

class SettingsState {
  final bool isGridView;
  final ThemeMode themeMode;
  final Locale locale;
  final bool showArchivesInHome;

  SettingsState({
    this.isGridView = true,
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.showArchivesInHome = true,
  });

  SettingsState copyWith({
    bool? isGridView,
    ThemeMode? themeMode,
    Locale? locale,
    bool? showArchivesInHome,
  }) {
    return SettingsState(
      isGridView: isGridView ?? this.isGridView,
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      showArchivesInHome: showArchivesInHome ?? this.showArchivesInHome,
    );
  }
}
