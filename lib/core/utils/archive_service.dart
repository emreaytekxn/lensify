import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/document.dart';

class ArchiveService {
  /// Zips a list of Documents into a single .zip file and returns its path.
  static Future<String?> zipDocuments(List<Document> documents, String zipName) async {
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
        if (doc.pdfPath != null) {
          final file = File(doc.pdfPath!);
          if (await file.exists()) {
            final ext = p.extension(doc.pdfPath!);
            final entryName = '${doc.title}$ext';
            encoder.addFile(file, entryName);
          }
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

      // Extract using archive_io
      await extractFileToDisk(zipPath, extractDir.path);

      // List all extracted files recursively
      List<String> extractedFiles = [];
      await for (var entity in extractDir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          extractedFiles.add(entity.path);
        }
      }

      return extractedFiles;
    } catch (e) {
      return [];
    }
  }
}
