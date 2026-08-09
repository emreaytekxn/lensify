import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/document.dart';
import '../../presentation/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArchiveService {
  /// Zips a list of Documents into a single .zip file and returns its path.
  static Future<String?> zipDocuments(List<Document> documents, String zipName, ProviderContainer container) async {
    try {
      if (documents.isEmpty) return null;

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final zipDir = Directory('${dir.path}/archives');
      if (!await zipDir.exists()) await zipDir.create(recursive: true);

      final safeName = zipName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-\s]'), '').trim();
      final zipPath = '${zipDir.path}/${safeName}_$timestamp.zip';

      var encoder = ZipFileEncoder();
      encoder.create(zipPath);

      for (var doc in documents) {
        if (doc.pdfPath != null && await File(doc.pdfPath!).exists()) {
          final file = File(doc.pdfPath!);
          final ext = p.extension(doc.pdfPath!);
          final entryName = '${doc.title}$ext';
          encoder.addFile(file, entryName);
        } else if (doc.id != null) {
          // If no PDF exists, zip its pages instead
          final repo = container.read(scannerRepositoryProvider);
          final pages = await repo.getPagesForDocument(doc.id!);
          for (var i = 0; i < pages.length; i++) {
            final page = pages[i];
            final imagePath = page.processedImagePath ?? page.originalImagePath;
            final file = File(imagePath);
            if (await file.exists()) {
              final ext = p.extension(imagePath);
              final entryName = '${doc.title}/Sayfa_${i + 1}$ext'; // Placed in a subfolder named after the document
              encoder.addFile(file, entryName);
            }
          }
        }
      }

      encoder.close();
      return zipPath;
    } catch (e) {
      return null;
    }
  }

  /// Zips a list of file paths into a single .zip file.
  static Future<String?> zipFiles(List<String> filePaths, String zipName) async {
    try {
      if (filePaths.isEmpty) return null;

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final zipDir = Directory('${dir.path}/archives');
      if (!await zipDir.exists()) await zipDir.create(recursive: true);

      final safeName = zipName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-\s]'), '').trim();
      final zipPath = '${zipDir.path}/${safeName}_$timestamp.zip';

      var encoder = ZipFileEncoder();
      encoder.create(zipPath);

      for (var path in filePaths) {
        final file = File(path);
        if (await file.exists()) {
          final entryName = p.basename(path);
          encoder.addFile(file, entryName);
        }
      }

      encoder.close();
      return zipPath;
    } catch (e) {
      return null;
    }
  }

  /// Unzips a file to a temporary directory and returns a list of extracted file paths.
  static Future<List<String>> unzipFile(String zipPath) async {
    try {
      final file = File(zipPath);
      if (!await file.exists()) return [];

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extractDir = Directory('${dir.path}/extracted_$timestamp');
      if (!await extractDir.exists()) await extractDir.create(recursive: true);

      // Extract using ZipDecoder manually
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final outFile = File('${extractDir.path}/$filename');
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(data);
        }
      }

      // List all extracted files recursively
      List<String> extractedFiles = [];
      await for (var entity in extractDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          extractedFiles.add(entity.path);
        }
      }

      return extractedFiles;
    } catch (e, st) {
      print("UNZIP ERROR: $e");
      print(st);
      return [];
    }
  }
}
