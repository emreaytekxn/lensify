import 'dart:io';
import 'package:image/image.dart' as img;
import '../../domain/entities/filter_type.dart';

class ImageFilterService {
  static Future<String> applyFilter(String imagePath, FilterType filter) async {
    if (filter == FilterType.original) return imagePath;

    final bytes = await File(imagePath).readAsBytes();
    img.Image? decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) return imagePath;

    switch (filter) {
      case FilterType.grayscale:
        decodedImage = img.grayscale(decodedImage);
        break;
      case FilterType.blackAndWhite:
        decodedImage = img.luminanceThreshold(decodedImage);
        break;
      case FilterType.magicColor:
        decodedImage =
            img.adjustColor(decodedImage, contrast: 1.5, saturation: 1.5);
        break;
      case FilterType.original:
        break;
    }

    final newPath = '${imagePath}_${filter.name}.jpg';
    final resultBytes = img.encodeJpg(decodedImage, quality: 90);
    await File(newPath).writeAsBytes(resultBytes);

    return newPath;
  }
}
