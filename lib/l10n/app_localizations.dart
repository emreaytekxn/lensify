import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kawaru'**
  String get appTitle;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Kawaru'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'The offline AI power that transforms everything. Scan, convert, and transcribe limitlessly.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'100% Offline & Free'**
  String get onboardingOfflineTitle;

  /// No description provided for @onboardingOfflineDesc.
  ///
  /// In en, this message translates to:
  /// **'No cloud, no subscriptions. Your privacy is secured on your device.'**
  String get onboardingOfflineDesc;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in Settings.'**
  String get onboardingLanguageDesc;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get startButton;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'All Documents'**
  String get homeTab;

  /// No description provided for @toolsTab.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsTab;

  /// No description provided for @settingsTab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @requireBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Require FaceID / TouchID on Startup'**
  String get requireBiometrics;

  /// No description provided for @requireBiometricsDesc.
  ///
  /// In en, this message translates to:
  /// **'Authentication is required every time you enter the app.'**
  String get requireBiometricsDesc;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Dark / Light Mode'**
  String get themeMode;

  /// No description provided for @legalAndDocs.
  ///
  /// In en, this message translates to:
  /// **'Legal & Documents'**
  String get legalAndDocs;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @kvkk.
  ///
  /// In en, this message translates to:
  /// **'KVKK Text'**
  String get kvkk;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @toolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsTitle;

  /// No description provided for @mediaConverter.
  ///
  /// In en, this message translates to:
  /// **'Media Converter'**
  String get mediaConverter;

  /// No description provided for @mediaConverterDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert images/videos to any format offline.'**
  String get mediaConverterDesc;

  /// No description provided for @aiTranscription.
  ///
  /// In en, this message translates to:
  /// **'AI Transcription'**
  String get aiTranscription;

  /// No description provided for @aiTranscriptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert audio to text perfectly offline.'**
  String get aiTranscriptionDesc;

  /// No description provided for @pdfEncrypt.
  ///
  /// In en, this message translates to:
  /// **'PDF Encryption'**
  String get pdfEncrypt;

  /// No description provided for @pdfEncryptDesc.
  ///
  /// In en, this message translates to:
  /// **'Protect your PDF files with a password.'**
  String get pdfEncryptDesc;

  /// No description provided for @universalMediaTools.
  ///
  /// In en, this message translates to:
  /// **'Universal Media Tools'**
  String get universalMediaTools;

  /// No description provided for @universalMediaToolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your files offline and securely with professional conversion tools.'**
  String get universalMediaToolsDesc;

  /// No description provided for @photoToPdf.
  ///
  /// In en, this message translates to:
  /// **'Photo to PDF'**
  String get photoToPdf;

  /// No description provided for @photoToPdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Combine multiple images into a single PDF document. (JPEG/PNG ➔ PDF)'**
  String get photoToPdfDesc;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importing;

  /// No description provided for @photosImportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Photos successfully imported!'**
  String get photosImportedSuccessfully;

  /// No description provided for @pdfToPhoto.
  ///
  /// In en, this message translates to:
  /// **'PDF to Photo'**
  String get pdfToPhoto;

  /// No description provided for @pdfToPhotoDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert PDF pages into high-resolution images. (PDF ➔ JPEG)'**
  String get pdfToPhotoDesc;

  /// No description provided for @pdfConverting.
  ///
  /// In en, this message translates to:
  /// **'Converting PDF...'**
  String get pdfConverting;

  /// No description provided for @pdfPagesConvertedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'PDF pages successfully converted to images!'**
  String get pdfPagesConvertedSuccessfully;

  /// No description provided for @qrBarcodeScan.
  ///
  /// In en, this message translates to:
  /// **'Scan QR / Barcode'**
  String get qrBarcodeScan;

  /// No description provided for @qrBarcodeScanDesc.
  ///
  /// In en, this message translates to:
  /// **'Quickly scan codes with your camera.'**
  String get qrBarcodeScanDesc;

  /// No description provided for @imageToText.
  ///
  /// In en, this message translates to:
  /// **'Image to Text (TXT)'**
  String get imageToText;

  /// No description provided for @imageToTextDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically convert text from photos to .txt format.'**
  String get imageToTextDesc;

  /// No description provided for @analyzingText.
  ///
  /// In en, this message translates to:
  /// **'Analyzing text...'**
  String get analyzingText;

  /// No description provided for @textFileCreated.
  ///
  /// In en, this message translates to:
  /// **'Text file created!'**
  String get textFileCreated;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @moveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to Folder'**
  String get moveToFolder;

  /// No description provided for @mainDir.
  ///
  /// In en, this message translates to:
  /// **'Main Directory (Remove from folder)'**
  String get mainDir;

  /// No description provided for @noOtherFolder.
  ///
  /// In en, this message translates to:
  /// **'No other folder found.'**
  String get noOtherFolder;

  /// No description provided for @searchDocs.
  ///
  /// In en, this message translates to:
  /// **'Search documents...'**
  String get searchDocs;

  /// No description provided for @appLocked.
  ///
  /// In en, this message translates to:
  /// **'App Locked'**
  String get appLocked;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
