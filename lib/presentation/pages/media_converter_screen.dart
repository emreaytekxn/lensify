import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/media_conversion_service.dart';
import '../widgets/loading_overlay.dart';

class MediaConverterScreen extends StatefulWidget {
  const MediaConverterScreen({super.key});

  @override
  State<MediaConverterScreen> createState() => _MediaConverterScreenState();
}

class _MediaConverterScreenState extends State<MediaConverterScreen> {
  String? _selectedFilePath;
  String? _selectedFileName;
  String _targetFormat = 'mp4';

  final List<String> _formats = [
    'mp4', 'mp3', 'wav', 'mkv', 'avi', 'gif', 'mov', 'aac', 'flac'
  ];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _convert() async {
    if (_selectedFilePath == null) return;

    LoadingOverlay.show(context, message: '$_targetFormat formatına dönüştürülüyor...\nBu işlem dosya boyutuna göre uzun sürebilir.');
    
    try {
      final outputPath = await MediaConversionService.convertMedia(_selectedFilePath!, _targetFormat);
      
      if (mounted) LoadingOverlay.hide(context);

      if (outputPath != null && mounted) {
        // Success
        await Share.shareXFiles(
          [XFile(outputPath)], 
          text: 'Lensify ile dönüştürüldü',
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dönüştürme başarısız oldu. Format desteklenmiyor olabilir.')),
        );
      }
    } catch (e) {
      if (mounted) LoadingOverlay.hide(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evrensel Dönüştürücü'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(CupertinoIcons.infinite, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 16),
            const Text(
              'Lensify Evrensel Dönüştürücü',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ses veya video dosyalarınızı internetsiz (çevrimdışı) olarak istediğiniz formata dönüştürün.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            
            // File Picker Button
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(CupertinoIcons.folder_badge_plus),
              label: Text(_selectedFileName ?? 'Dosya Seçin'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: _selectedFilePath != null ? Colors.green.withValues(alpha: 0.1) : null,
              ),
            ),
            const SizedBox(height: 24),
            
            // Format Selector
            if (_selectedFilePath != null) ...[
              const Text('Hedef Format:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _targetFormat,
                    isExpanded: true,
                    items: _formats.map((f) {
                      return DropdownMenuItem(
                        value: f,
                        child: Text(f.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _targetFormat = val);
                    },
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _convert,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Dönüştür', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ]
          ],
        ),
      ),
    );
  }
}
