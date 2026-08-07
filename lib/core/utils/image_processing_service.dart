import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/filter_type.dart';

class ImageProcessingService {
  /// Applies the selected filter to the image file using an Isolate (compute)
  /// so it doesn't freeze the main UI thread.
  static Future<File> applyFilter(File imageFile, FilterType filterType, String outputPath) async {
    if (filterType == FilterType.original) {
      // Fast path: just copy the file if original is selected
      return imageFile.copy(outputPath);
    }

    final imageBytes = await imageFile.readAsBytes();
    
    // Process in background isolate
    final processedBytes = await compute(_processImage, {
      'imageBytes': imageBytes,
      'filterType': filterType,
    });
    
    final outFile = File(outputPath);
    await outFile.writeAsBytes(processedBytes);
    return outFile;
  }

  // This function runs in a separate Isolate
  static Uint8List _processImage(Map<String, dynamic> args) {
    final Uint8List bytes = args['imageBytes'];
    final FilterType type = args['filterType'];
    
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return bytes;
    
    switch (type) {
      case FilterType.grayscale:
        img.grayscale(image);
        break;
      case FilterType.blackAndWhite:
        img.grayscale(image);
        img.luminanceThreshold(image, threshold: 0.5); // Threshold for B&W
        break;
      case FilterType.magicColor:
        // Magic color: increase contrast, brightness and slightly saturate
        // This is a basic approximation of what CamScanner does.
        img.adjustColor(
          image, 
          contrast: 1.5, 
          brightness: 1.2,
          saturation: 1.2,
        );
        break;
      case FilterType.original:
        break;
    }
    
    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  static Future<String?> combineIdCard(String frontPath, String backPath) async {
    try {
      final frontBytes = await File(frontPath).readAsBytes();
      final backBytes = await File(backPath).readAsBytes();

      final processedBytes = await compute(_combineIdCardIsolate, {
        'front': frontBytes,
        'back': backBytes,
      });

      if (processedBytes == null) return null;

      final tempDir = await getTemporaryDirectory();
      final outPath = '${tempDir.path}/id_card_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await File(outPath).writeAsBytes(processedBytes);
      return outPath;
    } catch (e) {
      return null;
    }
  }

  static Uint8List? _combineIdCardIsolate(Map<String, dynamic> args) {
    final Uint8List frontBytes = args['front'];
    final Uint8List backBytes = args['back'];

    final frontImage = img.decodeImage(frontBytes);
    final backImage = img.decodeImage(backBytes);

    if (frontImage == null || backImage == null) return null;

    const canvasWidth = 1240;
    const canvasHeight = 1754;
    final canvas = img.Image(width: canvasWidth, height: canvasHeight);
    img.fill(canvas, color: img.ColorRgb8(255, 255, 255));

    final targetWidth = (canvasWidth * 0.7).toInt();
    
    final resizedFront = img.copyResize(frontImage, width: targetWidth);
    final resizedBack = img.copyResize(backImage, width: targetWidth);

    final frontX = (canvasWidth - resizedFront.width) ~/ 2;
    final frontY = (canvasHeight ~/ 2 - resizedFront.height) ~/ 2;

    final backX = (canvasWidth - resizedBack.width) ~/ 2;
    final backY = (canvasHeight ~/ 2) + ((canvasHeight ~/ 2 - resizedBack.height) ~/ 2);

    img.compositeImage(canvas, resizedFront, dstX: frontX, dstY: frontY);
    img.compositeImage(canvas, resizedBack, dstX: backX, dstY: backY);

    return Uint8List.fromList(img.encodeJpg(canvas, quality: 90));
  }
}
