import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import '../../../domain/entities/document.dart';
import '../../providers/document_provider.dart';
import '../../providers/folder_provider.dart';
import '../../providers/core_providers.dart';
import '../../widgets/loading_overlay.dart';
import '../save_result_screen.dart';

class OcrScannerScreen extends ConsumerStatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  ConsumerState<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends ConsumerState<OcrScannerScreen> {
  String? _recognizedText;
  File? _selectedImage;
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _recognizedText = null;
      });
      _processImage();
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() => _isProcessing = true);
    
    try {
      final inputImage = InputImage.fromFile(_selectedImage!);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      setState(() {
        _recognizedText = recognizedText.text;
      });
      
      await textRecognizer.close();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _saveAsTextDocument() async {
    if (_recognizedText == null || _recognizedText!.isEmpty) return;

    LoadingOverlay.show(context, message: 'Belge hazırlanıyor...');
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final textDir = Directory('${appDir.path}/text_docs');
      if (!await textDir.exists()) {
        await textDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${textDir.path}/ocr_$timestamp.txt');
      await file.writeAsString(_recognizedText!);
      
      if (mounted) {
        LoadingOverlay.hide(context);
        final success = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SaveResultScreen(
              file: file,
              fileType: 'text',
              defaultTitle: 'OCR Metni',
              pageCount: 0,
            ),
          ),
        );
        
        if (success == true && mounted) {
          Navigator.pop(context); // Go back to tools screen
        }
      }
    } catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt hatası: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR (Metin Çıkarma)'),
      ),
      body: Column(
        children: [
          if (_selectedImage != null)
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.black12,
              child: Image.file(_selectedImage!, fit: BoxFit.contain),
            )
          else
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  'Metin çıkarmak için bir resim seçin',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ),
            ),
            
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: _isProcessing
                  ? const Center(child: CupertinoActivityIndicator())
                  : _recognizedText != null
                      ? SingleChildScrollView(
                          child: Text(
                            _recognizedText!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : const SizedBox(),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(CupertinoIcons.camera),
                      label: const Text('Kamera'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(CupertinoIcons.photo),
                      label: const Text('Galeri'),
                    ),
                  ),
                  if (_recognizedText != null && _recognizedText!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveAsTextDocument,
                        icon: const Icon(CupertinoIcons.doc_text),
                        label: const Text('Kaydet'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
