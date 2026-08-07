import 'package:whisper_flutter_new/whisper_flutter_new.dart';

class TranscriptionService {
  static Whisper? _whisper;
  
  /// Initializes the whisper model if not already done
  static Future<void> _initWhisper() async {
    if (_whisper != null) return;
    
    // Using tiny model for faster offline performance on mobile
    _whisper = const Whisper(
      model: WhisperModel.tiny,
      downloadHost: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main"
    );
  }
  
  /// Transcribes a 16kHz WAV file and returns the text
  static Future<String?> transcribeAudio(String audioPath) async {
    try {
      await _initWhisper();
      
      final response = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          isTranslate: false, // Don't translate, just transcribe original language
          isNoTimestamps: true, // Only raw text
          splitOnWord: false, 
        ),
      );
      
      return response.text;
    } catch (e) {
      return null;
    }
  }
}
