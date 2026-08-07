// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Kawaru';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Kawaru';

  @override
  String get onboardingWelcomeDesc =>
      'The offline AI power that transforms everything. Scan, convert, and transcribe limitlessly.';

  @override
  String get onboardingOfflineTitle => '100% Offline & Free';

  @override
  String get onboardingOfflineDesc =>
      'No cloud, no subscriptions. Your privacy is secured on your device.';

  @override
  String get onboardingLanguageTitle => 'Select Language';

  @override
  String get onboardingLanguageDesc => 'You can change this later in Settings.';

  @override
  String get startButton => 'Get Started';

  @override
  String get homeTab => 'All Documents';

  @override
  String get toolsTab => 'Tools';

  @override
  String get settingsTab => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';
}
