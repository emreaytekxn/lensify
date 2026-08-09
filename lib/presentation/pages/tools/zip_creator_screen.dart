import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/document.dart';
import '../../providers/document_provider.dart';
import '../../providers/core_providers.dart';
import '../../../core/utils/archive_service.dart';
import '../save_result_screen.dart';
import '../../widgets/loading_overlay.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class ZipCreatorScreen extends ConsumerStatefulWidget {
  const ZipCreatorScreen({super.key});

  @override
  ConsumerState<ZipCreatorScreen> createState() => _ZipCreatorScreenState();
}

class _ZipCreatorScreenState extends ConsumerState<ZipCreatorScreen> {
  final Set<int> _selectedIds = {};
  bool _isZipping = false;

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _createZip(List<Document> allDocs) async {
    if (_selectedIds.isEmpty) return;

    final selectedDocs = allDocs.where((d) => _selectedIds.contains(d.id)).toList();
    
    // Calculate Original Size
    int originalSizeBytes = 0;
    for (var doc in selectedDocs) {
      originalSizeBytes += doc.fileSize;
    }

    setState(() { _isZipping = true; });
    LoadingOverlay.show(context, message: 'Zipleniyor...');

    try {
      final zipPath = await ArchiveService.zipDocuments(
        selectedDocs, 
        'Archive_${DateTime.now().millisecondsSinceEpoch}',
        ProviderScope.containerOf(context)
      );

      if (zipPath != null && mounted) {
        final zipFile = File(zipPath);
        final zippedSizeBytes = await zipFile.length();
        if (!mounted) return;
        LoadingOverlay.hide(context);

        // Show Before/After Comparison
        final proceed = await _showSizeComparison(originalSizeBytes, zippedSizeBytes);
        if (proceed == true && mounted) {
          final success = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SaveResultScreen(
                file: zipFile,
                fileType: 'archive',
                defaultTitle: 'ZIP Arşivi - ${selectedDocs.length} Dosya',
                pageCount: 0,
              ),
            ),
          );
          if (success == true && mounted) {
            Navigator.pop(context); // Go back to Tools Screen
          }
        } else {
          // Cleanup if cancelled
          if (await zipFile.exists()) await zipFile.delete();
        }
      } else {
          if (mounted) {
              LoadingOverlay.hide(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zipleme başarısız oldu.')));
          }
      }
    } catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() { _isZipping = false; });
    }
  }

  Future<void> _pickFromDeviceAndZip() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result != null && result.files.isNotEmpty) {
        final filePaths = result.files.map((f) => f.path!).toList();
        
        int originalSizeBytes = 0;
        for (var path in filePaths) {
          originalSizeBytes += await File(path).length();
        }

        setState(() { _isZipping = true; });
        if (mounted) LoadingOverlay.show(context, message: 'Zipleniyor...');

        final zipPath = await ArchiveService.zipFiles(
          filePaths,
          'Archive_${DateTime.now().millisecondsSinceEpoch}',
        );

        if (zipPath != null && mounted) {
          final zipFile = File(zipPath);
          final zippedSizeBytes = await zipFile.length();
          if (!mounted) return;
          LoadingOverlay.hide(context);

          final proceed = await _showSizeComparison(originalSizeBytes, zippedSizeBytes);
          if (proceed == true && mounted) {
            final success = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SaveResultScreen(
                  file: zipFile,
                  fileType: 'archive',
                  defaultTitle: 'Cihazdan ZIP - ${filePaths.length} Dosya',
                  pageCount: 0,
                ),
              ),
            );
            if (success == true && mounted) {
              Navigator.pop(context);
            }
          } else {
            if (await zipFile.exists()) await zipFile.delete();
          }
        } else {
          if (mounted) {
            LoadingOverlay.hide(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zipleme başarısız oldu.')));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() { _isZipping = false; });
    }
  }

  Future<bool?> _showSizeComparison(int original, int zipped) {
    String formatBytes(int bytes) {
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Zipleme Tamamlandı 🎉', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_zip, size: 64, color: Colors.orange),
              const SizedBox(height: 24),
              if (zipped > original)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    '(Sıkıştırılmış medya dosyaları tekrar sıkıştırılamadığından boyut aynı kalabilir veya paketlemeden dolayı çok az artabilir.)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text('Önce', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(formatBytes(original), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: zipped <= original ? Colors.redAccent : Colors.grey)),
                    ],
                  ),
                  const Icon(CupertinoIcons.arrow_right, color: Colors.grey),
                  Column(
                    children: [
                      const Text('Sonra', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(formatBytes(zipped), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: zipped < original ? Colors.green : Colors.orange)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
              child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final docState = ref.watch(documentNotifierProvider);
    final documents = docState.allDocuments.where((d) => d.fileType != 'archive').toList();
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZIP Oluşturucu'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.folder_badge_plus),
            tooltip: 'Cihazdan Seç',
            onPressed: _isZipping ? null : _pickFromDeviceAndZip,
          ),
          if (_selectedIds.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _selectedIds.clear()),
              child: const Text('Temizle', style: TextStyle(color: Colors.red)),
            )
        ],
      ),
      body: documents.isEmpty
          ? const Center(child: Text('Kasanızda dosya bulunmuyor.'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                final isSelected = _selectedIds.contains(doc.id);
                return ListTile(
                  leading: Icon(
                    doc.fileType == 'pdf' ? CupertinoIcons.doc_fill : CupertinoIcons.photo_fill,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(dateFormat.format(doc.createdAt)),
                  trailing: isSelected
                      ? Icon(CupertinoIcons.check_mark_circled_solid, color: Theme.of(context).primaryColor)
                      : const Icon(CupertinoIcons.circle, color: Colors.grey),
                  onTap: () => _toggleSelection(doc.id!),
                );
              },
            ),
      floatingActionButton: _selectedIds.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _isZipping ? null : () => _createZip(documents),
              backgroundColor: Theme.of(context).primaryColor,
              icon: const Icon(CupertinoIcons.archivebox_fill, color: Colors.white),
              label: Text(
                '${_selectedIds.length} Dosyayı Ziple',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
