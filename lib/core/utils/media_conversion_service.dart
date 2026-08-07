import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

class MediaConversionService {
  
  /// Converts any media file to the target extension using FFmpeg (Actual implementation)
  static Future<String?> convertMedia(String inputPath, String targetExtension) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final originalName = inputPath.split('/').last;
      final nameWithoutExt = originalName.substring(0, originalName.lastIndexOf('.'));
      
      final String outputPath = '${tempDir.path}/${nameWithoutExt}_kawaru.$targetExtension';
      
      if (File(outputPath).existsSync()) {
        File(outputPath).deleteSync();
      }

      // Simple copy/re-encode command
      String command;
      if (targetExtension.toLowerCase() == 'wav') {
        // Whisper requires 16kHz, mono, 16-bit WAV
        command = '-y -i "$inputPath" -ar 16000 -ac 1 -c:a pcm_s16le "$outputPath"';
      } else {
        command = '-y -i "$inputPath" "$outputPath"';
      }
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      } else {
        final logs = await session.getLogs();
        for (var log in logs) {
          print(log.getMessage());
        }
        return null;
      }
    } catch (e) {
      print('Media Conversion Error: $e');
      return null;
    }
  }
}
