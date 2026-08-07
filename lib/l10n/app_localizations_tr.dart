// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Kawaru';

  @override
  String get onboardingWelcomeTitle => 'Kawaru\'ya Hoş Geldiniz';

  @override
  String get onboardingWelcomeDesc =>
      'Her şeyi dönüştüren yapay zeka gücü. Sınır tanımadan tarayın, dönüştürün ve yazıya çevirin.';

  @override
  String get onboardingOfflineTitle => '%100 Çevrimdışı ve Ücretsiz';

  @override
  String get onboardingOfflineDesc =>
      'Bulut yok, abonelik yok. Tüm gizliliğiniz cihazınızda kalır.';

  @override
  String get onboardingLanguageTitle => 'Dil Seçimi';

  @override
  String get onboardingLanguageDesc =>
      'Bunu daha sonra Ayarlar\'dan değiştirebilirsiniz.';

  @override
  String get startButton => 'Başla';

  @override
  String get homeTab => 'Tüm Belgeler';

  @override
  String get toolsTab => 'Araçlar';

  @override
  String get settingsTab => 'Ayarlar';

  @override
  String get language => 'Dil';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Karanlık Mod';

  @override
  String get lightMode => 'Aydınlık Mod';
}
