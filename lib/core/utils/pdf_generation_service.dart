import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerationService {
  /// Generates a PDF file from a list of image paths using an Isolate (compute)
  /// so it doesn't freeze the main UI thread during generation.
  static Future<File> generatePdf(List<String> imagePaths, String outputPath) async {
    // Process in background isolate
    final pdfBytes = await compute(_generatePdfIsolate, {
      'imagePaths': imagePaths,
    });
    
    final outFile = File(outputPath);
    await outFile.writeAsBytes(pdfBytes);
    return outFile;
  }

  // This function runs in a separate Isolate
  static Future<Uint8List> _generatePdfIsolate(Map<String, dynamic> args) async {
    final List<String> paths = args['imagePaths'];
    final pdf = pw.Document();

    for (final path in paths) {
      final file = File(path);
      if (!file.existsSync()) continue;

      // Load image bytes
      final bytes = await file.readAsBytes();
      
      // Use MemoryImage from pdf package
      final imageProvider = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero, // Full page fit
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                imageProvider, 
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );
    }

    return await pdf.save();
  }
}
