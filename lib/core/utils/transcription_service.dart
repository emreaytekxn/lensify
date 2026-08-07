import 'dart:convert';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

class TranscriptionService {
  static Whisper? _whisper;
  
  /// Initializes the whisper model if not already done
  static Future<void> _initWhisper() async {
    if (_whisper != null) return;
    
    // Using tiny model for faster offline performance on mobile
    _whisper = Whisper(
      model: WhisperModel.tiny,
      downloadHost: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main"
    );
  }
  
  /// Transcribes a 16kHz WAV file and returns the text
  static Future<String?> transcribeAudio(String audioPath) async {
    try {
      await _initWhisper();
      
      final transcription = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          isTranslate: false, // Don't translate, just transcribe original language
          isNoTimestamps: true, // Only raw text
          splitOnWord: false, 
        ),
      );
      
      // The transcription returns a JSON string, we need to parse it
      // Usually it has a 'text' field.
      try {
        final Map<String, dynamic> data = jsonDecode(transcription);
        return data['text']?.toString().trim();
      } catch (e) {
        // If it's not JSON, maybe it returns raw text
        return transcription.trim();
      }
    } catch (e) {
      print('Transcription Error: $e');
      return null;
    }
  }
}
