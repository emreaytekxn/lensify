import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'ocr_service.dart';
import 'package:flutter/material.dart';

class FormatConversionService {
  
  /// Extracts text from an image and exports it as a .txt file
  static Future<bool> extractTextToTxt() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return false;

    final String text = await OcrService.extractText(image.path);
    if (text.isEmpty) {
      throw Exception('Resimden okunabilir metin bulunamadı.');
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/CikarilanMetin_${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(text);

    await Share.shareXFiles([XFile(file.path)], text: 'Lensify ile çıkarılan metin dosyası');
    return true;
  }

  /// encrypts a picked PDF with a password and exports it
  static Future<bool> encryptPdf(String password) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return false;

    final inputBytes = await File(result.files.single.path!).readAsBytes();
    
    // Load the document
    final PdfDocument document = PdfDocument(inputBytes: inputBytes);
    
    // Create security policy
    final PdfSecurity security = document.security;
    security.userPassword = password;
    security.ownerPassword = password;
    security.algorithm = PdfEncryptionAlgorithm.aesx256Bit;
    
    // Save the document
    final List<int> bytes = await document.save();
    document.dispose();

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/Sifreli_${result.files.single.name}');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], text: 'Lensify ile şifrelenmiş PDF');
    return true;
  }
}
