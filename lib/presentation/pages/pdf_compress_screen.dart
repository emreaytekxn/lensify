import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../core/utils/pdf_tools_service.dart';
import '../widgets/loading_overlay.dart';
import 'save_result_screen.dart';

class PdfCompressScreen extends StatefulWidget {
  const PdfCompressScreen({super.key});

  @override
  State<PdfCompressScreen> createState() => _PdfCompressScreenState();
}

class _PdfCompressScreenState extends State<PdfCompressScreen> {
  PlatformFile? _selectedFile;
  bool _isProcessing = false;
  double _compressionLevel = 1.0; // 0 to 3

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.single;
      });
    }
  }

  Future<void> _compressPdf() async {
    if (_selectedFile == null) return;

    setState(() {
      _isProcessing = true;
    });
    
    LoadingOverlay.show(context, message: 'PDF Sıkıştırılıyor...');

    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      await PdfToolsService.compressPdf(_selectedFile!.path!, outputPath, _compressionLevel.toInt());

      final outInfo = File(outputPath);
      final newSize = await outInfo.length();

      if (mounted) {
        LoadingOverlay.hide(context);
        
        final oldSizeMb = _selectedFile!.size / 1024 / 1024;
        final newSizeMb = newSize / 1024 / 1024;
        
        final shouldSave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sıkıştırma Tamamlandı 📉'),
            content: Text('Eski Boyut: ${oldSizeMb.toStringAsFixed(2)} MB\n'
                'Yeni Boyut: ${newSizeMb.toStringAsFixed(2)} MB\n\n'
                'Bu dosyayı kaydetmek istiyor musunuz?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Vazgeç', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Evet, Kaydet'),
              ),
            ],
          ),
        );
        
        if (shouldSave == true && mounted) {
          final saveResult = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SaveResultScreen(
                file: File(outputPath),
                fileType: 'pdf',
                defaultTitle: 'Sikistirilmis_PDF_${DateTime.now().millisecondsSinceEpoch}',
              ),
            ),
          );
          
          if (saveResult == true && mounted) {
            setState(() {
              _selectedFile = null;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
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

  String _getLevelText() {
    switch (_compressionLevel.toInt()) {
      case 0: return 'Düşük Sıkıştırma (Yüksek Kalite)';
      case 1: return 'Dengeli';
      case 2: return 'Yüksek Sıkıştırma (Düşük Kalite)';
      case 3: return 'Maksimum Sıkıştırma';
      default: return 'Dengeli';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Sıkıştır'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_selectedFile == null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.arrow_down_doc, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('Boyutunu küçültmek istediğiniz PDF\'i seçin'),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _pickFile,
                            icon: const Icon(CupertinoIcons.folder),
                            label: const Text('Dosya Seç'),
                          )
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Column(
                      children: [
                        Card(
                          child: ListTile(
                            leading: const Icon(CupertinoIcons.doc_fill, color: Colors.red),
                            title: Text(_selectedFile!.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text('Orijinal Boyut: ${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB'),
                            trailing: IconButton(
                              icon: const Icon(CupertinoIcons.clear_circled),
                              onPressed: () => setState(() => _selectedFile = null),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text('Sıkıştırma Seviyesi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Text(_getLevelText(), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                        Slider(
                          value: _compressionLevel,
                          min: 0,
                          max: 3,
                          divisions: 3,
                          onChanged: (val) {
                            setState(() {
                              _compressionLevel = val;
                            });
                          },
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _compressPdf,
                          icon: const Icon(CupertinoIcons.arrow_down_right_arrow_up_left),
                          label: const Text('Sıkıştırmaya Başla'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        )
                      ],
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
