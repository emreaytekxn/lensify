import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../../domain/entities/document.dart';
import '../../providers/core_providers.dart';
import '../../providers/document_provider.dart';
import '../../providers/folder_provider.dart';
import '../../widgets/loading_overlay.dart';

class HeicConverterScreen extends ConsumerStatefulWidget {
  const HeicConverterScreen({super.key});

  @override
  ConsumerState<HeicConverterScreen> createState() => _HeicConverterScreenState();
}

class _HeicConverterScreenState extends ConsumerState<HeicConverterScreen> {
  String? _selectedFilePath;
  bool _isConverting = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['heic', 'heif', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
      });
    }
  }

  Future<void> _convertToJpg() async {
    if (_selectedFilePath == null) return;
    
    setState(() => _isConverting = true);
    LoadingOverlay.show(context, message: 'Dönüştürülüyor...');

    try {
      final file = File(_selectedFilePath!);
      final dir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${dir.path}/images');
      if (!await targetDir.exists()) await targetDir.create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = '${targetDir.path}/img_$timestamp.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 90,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final folderId = ref.read(folderNotifierProvider).activeFolderId;
        final repo = ref.read(scannerRepositoryProvider);
        
        final doc = Document(
          title: 'Dönüştürülen Görsel',
          folderId: folderId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          pageCount: 0,
          pdfPath: result.path,
          isFavorite: false,
          fileSize: await File(result.path).length(),
          fileType: 'image',
        );
        
        await repo.createDocument(doc);
        await ref.read(documentNotifierProvider.notifier).loadDocuments();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('JPG olarak kaydedildi!')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception("Dönüştürme başarısız oldu.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      setState(() => _isConverting = false);
      if (mounted) LoadingOverlay.hide(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HEIC to JPG')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(CupertinoIcons.photo, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 24),
            const Text(
              'Apple HEIC fotoğraflarınızı kayıpsız bir şekilde evrensel JPG formatına dönüştürün.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            if (_selectedFilePath != null) ...[
              const Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.green, size: 40),
              const SizedBox(height: 8),
              Text(
                _selectedFilePath!.split('/').last,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton.icon(
              onPressed: _isConverting ? null : _pickFile,
              icon: const Icon(CupertinoIcons.folder),
              label: Text(_selectedFilePath == null ? 'Fotoğraf Seç' : 'Başka Seç'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _selectedFilePath == null || _isConverting ? null : _convertToJpg,
              icon: const Icon(CupertinoIcons.arrow_right_circle_fill),
              label: const Text('JPG Olarak Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
