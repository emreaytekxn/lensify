import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    await _flutterTts.setLanguage("tr-TR"); // Default to Turkish
    await _flutterTts.setSpeechRate(0.5); // Normal speed
    await _flutterTts.setVolume(1.0); // Max volume
    await _flutterTts.setPitch(1.0); // Normal pitch
    _isInitialized = true;
  }

  static Future<void> speak(String text) async {
    await init();
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
  }

  static Future<void> setLanguage(String languageCode) async {
    await _flutterTts.setLanguage(languageCode);
  }
}
