import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/document.dart';
import '../../domain/entities/document_page.dart';
import '../../domain/entities/filter_type.dart';
import '../../domain/repositories/scanner_repository.dart';

class DocumentImportService {
  final ScannerRepository _repository;

  DocumentImportService(this._repository);

  Future<void> importFromGallery(int? targetFolderId) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      imageQuality: 100,
    );

    if (images.isNotEmpty) {
      await _createDocumentFromImages(
        images.map((f) => f.path).toList(),
        "Galeriden İçe Aktarıldı",
        targetFolderId,
      );
    }
  }

  Future<void> importPdf(int? targetFolderId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final pdfPath = result.files.single.path!;
      final docName = result.files.single.name.replaceAll('.pdf', '');
      
      try {
        final document = await PdfDocument.openFile(pdfPath);
        List<String> imagePaths = [];
        
        final tempDir = await getTemporaryDirectory();
        
        for (int i = 1; i <= document.pagesCount; i++) {
          final page = await document.getPage(i);
          // Render at 2x resolution for better quality
          final pageImage = await page.render(
            width: page.width * 2,
            height: page.height * 2,
            format: PdfPageImageFormat.jpeg,
          );
          
          if (pageImage != null) {
            final imgFile = File('${tempDir.path}/pdf_page_${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
            await imgFile.writeAsBytes(pageImage.bytes);
            imagePaths.add(imgFile.path);
          }
          await page.close();
        }
        await document.close();
        
        if (imagePaths.isNotEmpty) {
          await _createDocumentFromImages(imagePaths, docName, targetFolderId);
        }
      } catch (e) {
        debugPrint("PDF Import Error: $e");
      }
    }
  }

  Future<void> _createDocumentFromImages(List<String> imagePaths, String title, int? folderId) async {
    final doc = Document(
      title: title,
      folderId: folderId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      pageCount: imagePaths.length,
    );
    
    final createdDoc = await _repository.createDocument(doc);
    
    int pageIndex = 0;
    for (String path in imagePaths) {
      final page = DocumentPage(
        documentId: createdDoc.id!,
        originalImagePath: path,
        processedImagePath: path, // No filter by default for batch imports
        appliedFilter: FilterType.original,
        pageIndex: pageIndex,
        createdAt: DateTime.now(),
      );
      await _repository.addPageToDocument(page);
      pageIndex++;
    }
  }
}
