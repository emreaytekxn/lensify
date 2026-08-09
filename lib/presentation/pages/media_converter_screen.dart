import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/kawaru_text.dart';
import '../../core/utils/media_conversion_service.dart';
import '../widgets/loading_overlay.dart';
import 'dart:io';
import 'save_result_screen.dart';

class MediaConverterScreen extends StatefulWidget {
  const MediaConverterScreen({super.key});

  @override
  State<MediaConverterScreen> createState() => _MediaConverterScreenState();
}

class _MediaConverterScreenState extends State<MediaConverterScreen> {
  String? _selectedFilePath;
  String? _selectedFileName;
  String _targetFormat = 'mp4';

  final List<String> _formats = ['mp4', 'mov', 'mp3', 'wav', 'm4a'];

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

    LoadingOverlay.show(context,
        message:
            '$_targetFormat formatına dönüştürülüyor...\nBu işlem dosya boyutuna göre uzun sürebilir.');

    try {
      final outputPath = await MediaConversionService.convertMedia(
          _selectedFilePath!, _targetFormat);

      if (mounted) LoadingOverlay.hide(context);

      if (outputPath != null && mounted) {
        // Success
        final saveResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SaveResultScreen(
              file: File(outputPath),
              fileType: _targetFormat == 'mp4' || _targetFormat == 'mov' 
                  ? 'video' 
                  : 'audio',
              defaultTitle: 'Donusturulmus_Medya_${DateTime.now().millisecondsSinceEpoch}',
            ),
          ),
        );
        if (saveResult == true && mounted) {
          setState(() {
            _selectedFilePath = null;
            _selectedFileName = null;
          });
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Dönüştürme başarısız oldu. Format desteklenmiyor olabilir.')),
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
            const Icon(CupertinoIcons.infinite,
                size: 80, color: Colors.blueAccent),
            const SizedBox(height: 16),
            const KawaruText(
              'Kawaru Evrensel Dönüştürücü',
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
                backgroundColor: _selectedFilePath != null
                    ? Colors.green.withValues(alpha: 0.1)
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // Format Selector
            if (_selectedFilePath != null) ...[
              const SizedBox(height: 16),
              const Text('Hedef Formatı Seçin',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _formats.map((f) {
                  final isSelected = _targetFormat == f;
                  final isVideo = f == 'mp4' || f == 'mov';
                  final isAudio = f == 'mp3' || f == 'wav' || f == 'm4a';
                  return ChoiceChip(
                    label: Text(f.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _targetFormat = f);
                    },
                    avatar: Icon(
                      isVideo
                          ? CupertinoIcons.film
                          : isAudio
                              ? CupertinoIcons.music_note
                              : CupertinoIcons.photo,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Simulated Quality Selector
              const Text('Kalite',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: const ListTile(
                  leading: Icon(CupertinoIcons.sparkles, color: Colors.amber),
                  title: Text('Orijinal Kaliteyi Koru'),
                  subtitle: Text('Kayıpsız dönüştürme (Önerilen)'),
                  trailing: Icon(CupertinoIcons.checkmark_alt, color: Colors.green),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _convert,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.arrow_right_arrow_left, size: 24),
                      SizedBox(width: 12),
                      Text('Şimdi Dönüştür',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ]
          ],
        ),
      ),
    );
  }
}
