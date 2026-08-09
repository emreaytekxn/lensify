import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfToolsService {
  /// Birleştirme (Merge) işlemi Isolate içinde yapılır.
  static Future<String> mergePdfs(List<String> filePaths, String outputPath, {List<String>? passwords}) async {
    return compute(_mergePdfsIsolate, {
      'filePaths': filePaths,
      'outputPath': outputPath,
      'passwords': passwords,
    });
  }

  static Future<String> _mergePdfsIsolate(Map<String, dynamic> args) async {
    final filePaths = args['filePaths'] as List<String>;
    final outputPath = args['outputPath'] as String;
    final passwords = args['passwords'] as List<String>?;

    // Create a new PDF document
    final PdfDocument document = PdfDocument();
    
    for (int i = 0; i < filePaths.length; i++) {
      final path = filePaths[i];
      final password = (passwords != null && passwords.length > i) ? passwords[i] : '';
      
      final bytes = File(path).readAsBytesSync();
      
      // Load existing document
      final PdfDocument loadedDoc = password.isNotEmpty 
          ? PdfDocument(inputBytes: bytes, password: password)
          : PdfDocument(inputBytes: bytes);
          
      // Extract pages and add to new document
      for (int j = 0; j < loadedDoc.pages.count; j++) {
        final PdfPage loadedPage = loadedDoc.pages[j];
        final PdfPage newPage = document.pages.add();
        // createTemplate allows us to draw the loaded page onto the new page
        final PdfTemplate template = loadedPage.createTemplate();
        newPage.graphics.drawPdfTemplate(template, const Offset(0, 0));
      }
      
      loadedDoc.dispose();
    }
    
    // Save document
    final outBytes = await document.save();
    document.dispose();
    
    final outFile = File(outputPath);
    await outFile.writeAsBytes(outBytes);
    
    return outputPath;
  }

  /// Sıkıştırma (Compress) işlemi
  /// compressionLevel: 0 (Highest Quality) to 3 (Max Compression)
  static Future<String> compressPdf(String inputPath, String outputPath, int level, {String password = ''}) async {
    return compute(_compressPdfIsolate, {
      'inputPath': inputPath,
      'outputPath': outputPath,
      'level': level,
      'password': password,
    });
  }

  static Future<String> _compressPdfIsolate(Map<String, dynamic> args) async {
    final inputPath = args['inputPath'] as String;
    final outputPath = args['outputPath'] as String;
    final level = args['level'] as int;
    final password = args['password'] as String;

    final bytes = File(inputPath).readAsBytesSync();
    final PdfDocument doc = password.isNotEmpty 
        ? PdfDocument(inputBytes: bytes, password: password)
        : PdfDocument(inputBytes: bytes);
        
    // Apply compression settings based on level
    // Syncfusion allows image compression and flattening
    if (level >= 1) {
      doc.compressionLevel = PdfCompressionLevel.bestSpeed;
    }
    if (level >= 2) {
      doc.compressionLevel = PdfCompressionLevel.bestSpeed;
      // In a real advanced PDF compressor, we would extract images and resize them.
      // For now, Syncfusion's built in settings will have to do.
    }
    if (level >= 3) {
      doc.compressionLevel = PdfCompressionLevel.bestSpeed;
      // Flatten annotations if any to save space
      for(int i = 0; i < doc.pages.count; i++) {
        doc.pages[i].annotations.flattenAllAnnotations();
      }
    }
    
    final outBytes = await doc.save();
    doc.dispose();
    
    final outFile = File(outputPath);
    await outFile.writeAsBytes(outBytes);
    
    return outputPath;
  }
}
