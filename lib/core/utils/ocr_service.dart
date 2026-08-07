import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  static Future<String> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint("OCR Error: $e");
      return "Metin çıkarılamadı: $e";
    }
  }

  static void dispose() {
    _textRecognizer.close();
  }
}
