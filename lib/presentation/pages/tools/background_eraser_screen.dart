import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/utils/background_remover_service.dart';
import '../../../domain/entities/document.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/document_provider.dart';
import '../../providers/core_providers.dart';
import '../../providers/folder_provider.dart';

class BackgroundEraserScreen extends ConsumerStatefulWidget {
  const BackgroundEraserScreen({super.key});

  @override
  ConsumerState<BackgroundEraserScreen> createState() => _BackgroundEraserScreenState();
}

class _BackgroundEraserScreenState extends ConsumerState<BackgroundEraserScreen> {
  File? _selectedImage;
  File? _processedImage;
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
          _processedImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final resultFile = await BackgroundRemoverService.removeBackground(_selectedImage!);
      setState(() {
        _processedImage = resultFile;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _saveToVault() async {
    if (_processedImage == null) return;

    final fileName = 'BG_Removed_${DateTime.now().millisecondsSinceEpoch}.png';
    final repo = ref.read(scannerRepositoryProvider);
    final folderId = ref.read(folderNotifierProvider).activeFolderId;

    final doc = Document(
      title: fileName,
      folderId: folderId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      pageCount: 0,
      pdfPath: _processedImage!.path,
      fileType: 'image',
      fileSize: await _processedImage!.length(),
    );

    await repo.createDocument(doc);
    await ref.read(documentNotifierProvider.notifier).loadDocuments();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kasaya kaydedildi: $fileName')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.backgroundEraser),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _isProcessing
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text('Arka plan temizleniyor, lütfen bekleyin...',
                              style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      )
                    : _processedImage != null
                        ? Image.file(_processedImage!)
                        : _selectedImage != null
                            ? Image.file(_selectedImage!)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.person_crop_rectangle,
                                      size: 80,
                                      color: isDark ? Colors.white30 : Colors.black26),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Arka planı silinecek portreyi seçin',
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_processedImage != null)
                      ElevatedButton.icon(
                        onPressed: _saveToVault,
                        icon: const Icon(CupertinoIcons.lock_shield),
                        label: const Text('Kasaya Kaydet'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      )
                    else if (_selectedImage != null && !_isProcessing)
                      ElevatedButton.icon(
                        onPressed: _processImage,
                        icon: const Icon(CupertinoIcons.wand_rays),
                        label: const Text('Arka Planı Sil'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      )
                    else if (!_isProcessing)
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(CupertinoIcons.photo_fill_on_rectangle_fill),
                        label: const Text('Galeriden Seç'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    if (_processedImage != null || _selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: TextButton(
                          onPressed: _isProcessing ? null : _pickImage,
                          child: const Text('Farklı Bir Görsel Seç'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
