import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/batch_conversion_provider.dart';
import '../providers/folder_provider.dart';
import '../providers/core_providers.dart';
import '../../domain/entities/batch_item.dart';
import '../../domain/entities/document.dart' as doc_entity;
import '../../l10n/app_localizations.dart';

class BatchSaveResultScreen extends ConsumerStatefulWidget {
  const BatchSaveResultScreen({super.key});

  @override
  ConsumerState<BatchSaveResultScreen> createState() => _BatchSaveResultScreenState();
}

class _BatchSaveResultScreenState extends ConsumerState<BatchSaveResultScreen> {
  int? _selectedFolderId;
  bool _isSaving = false;

  Future<void> _saveAll() async {
    final loc = AppLocalizations.of(context)!;
    final state = ref.read(batchConversionProvider);
    final completedItems = state.items.where((e) => e.status == BatchItemStatus.completed).toList();

    if (completedItems.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = ref.read(scannerRepositoryProvider);
      for (var item in completedItems) {
        if (item.outputPath != null) {
          final file = File(item.outputPath!);
          if (await file.exists()) {
            final fileName = item.sourceFileName.split('.').first;
            final doc = doc_entity.Document(
              title: '${fileName}_${item.targetFormat.toUpperCase()}',
              pdfPath: item.outputPath!,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              pageCount: 1,
              fileType: _mapType(item.targetFormat),
              fileSize: await file.length(),
              folderId: _selectedFolderId,
            );
            await repo.createDocument(doc);
          }
        }
      }

      // Clear completed items from the batch queue
      await ref.read(batchConversionProvider.notifier).clearCompleted();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${completedItems.length} dosya kasaya kaydedildi!')),
        );
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.error}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _mapType(String format) {
    switch (format.toLowerCase()) {
      case 'pdf': return 'pdf';
      case 'txt': return 'text';
      case 'mp4': 
      case 'mov':
      case 'mp3':
      case 'wav':
      case 'm4a': return 'media';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif': return 'image';
      default: return 'pdf';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchConversionProvider);
    final completedItems = state.items.where((e) => e.status == BatchItemStatus.completed).toList();
    final folderState = ref.watch(folderNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toplu Kayıt'),
      ),
      body: _isSaving
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CupertinoActivityIndicator(radius: 20),
                  const SizedBox(height: 16),
                  Text('Dosyalar kasaya şifreleniyor...', style: TextStyle(color: Theme.of(context).primaryColor)),
                ],
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(CupertinoIcons.checkmark_seal_fill, size: 80, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(
                      '${completedItems.length} İşlem Tamamlandı',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tüm dosyaları kasanızdaki bir klasöre topluca kaydedebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    const Text('Hedef Klasör:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    if (folderState.isLoading)
                      const CupertinoActivityIndicator()
                    else if (folderState.error != null)
                      const Text('Klasörler yüklenemedi.')
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: _selectedFolderId,
                            isExpanded: true,
                            hint: const Text('Ana Dizin (Klasörsüz)'),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Ana Dizin'),
                              ),
                              ...folderState.folders.map((f) => DropdownMenuItem(
                                    value: f.id,
                                    child: Text('📁 ${f.name}'),
                                  )),
                            ],
                            onChanged: (val) => setState(() => _selectedFolderId = val),
                          ),
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _saveAll,
                      icon: const Icon(CupertinoIcons.lock_shield_fill),
                      label: const Text('Hepsini Kaydet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
