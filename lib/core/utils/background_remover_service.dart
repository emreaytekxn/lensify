import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class _IsolateData {
  final img.Image image;
  final List<double> confidences;
  final int maskWidth;
  final int maskHeight;

  _IsolateData(this.image, this.confidences, this.maskWidth, this.maskHeight);
}

img.Image _applyMaskInIsolate(_IsolateData data) {
  img.Image image = data.image;
  final confidences = data.confidences;
  final maskWidth = data.maskWidth;
  final maskHeight = data.maskHeight;

  // Ensure image has an alpha channel
  if (!image.hasAlpha) {
    image = image.convert(numChannels: 4);
  }

  for (final pixel in image) {
    final maskX = (pixel.x * maskWidth / image.width).floor();
    final maskY = (pixel.y * maskHeight / image.height).floor();
    final index = maskY * maskWidth + maskX;

    if (index < confidences.length) {
      if (confidences[index] < 0.5) {
        // Set alpha to 0 (transparent) for background
        pixel.a = 0;
      }
    }
  }

  return image;
}

class BackgroundRemoverService {
  static Future<File?> removeBackground(File imageFile) async {
    // 1. Check platform
    if (!Platform.isIOS && !Platform.isAndroid) {
      throw Exception('Arka plan silici sadece iOS ve Android platformlarında çalışır.');
    }

    final inputImage = InputImage.fromFile(imageFile);
    final segmenter = SelfieSegmenter(
      mode: SegmenterMode.single,
      enableRawSizeMask: true,
    );

    try {
      // 2. Get Mask
      final mask = await segmenter.processImage(inputImage);
      if (mask == null) {
        throw Exception('Maske oluşturulamadı.');
      }

      // 3. Decode original image
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        throw Exception('Fotoğraf okunamadı.');
      }

      // 4. Apply mask in isolate to prevent UI freezing
      final processedImage = await compute(
        _applyMaskInIsolate,
        _IsolateData(originalImage, mask.confidences, mask.width, mask.height),
      );

      // 5. Encode to PNG
      final pngBytes = img.encodePng(processedImage);

      // 6. Save to temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/bg_removed_$timestamp.png');
      await tempFile.writeAsBytes(pngBytes);

      return tempFile;
    } finally {
      segmenter.close();
    }
  }
}
