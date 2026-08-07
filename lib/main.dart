import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'presentation/pages/main_navigation_screen.dart';
import 'presentation/pages/animated_splash_screen.dart';
import 'presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  runApp(const ProviderScope(child: KawaruApp()));
}

class KawaruApp extends ConsumerWidget {
  const KawaruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);

    return MaterialApp(
      title: 'Kawaru',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsState.themeMode,
      home: const AnimatedSplashScreen(),
    );
  }
}
