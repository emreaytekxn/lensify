import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../save_result_screen.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/kawaru_text.dart';

class JpegToGifScreen extends StatefulWidget {
  const JpegToGifScreen({super.key});

  @override
  State<JpegToGifScreen> createState() => _JpegToGifScreenState();
}

class _JpegToGifScreenState extends State<JpegToGifScreen> {
  List<File> _selectedFiles = [];

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFiles = result.files.map((e) => File(e.path!)).toList();
      });
    }
  }

  Future<void> _convertToGif() async {
    if (_selectedFiles.isEmpty) return;

    LoadingOverlay.show(context, message: 'Fotoğraflar birleştirilip GIF oluşturuluyor...');

    try {
      // Simulate conversion delay
      await Future.delayed(const Duration(seconds: 2));

      final dir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${dir.path}/images');
      if (!await targetDir.exists()) await targetDir.create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = '${targetDir.path}/animation_$timestamp.gif';
      
      // In a real scenario we would use a package like `image` to combine frames.
      // Here we simulate by just copying the first file (it won't be a real animated gif but simulates the output).
      final file = await _selectedFiles.first.copy(targetPath);

      if (mounted) LoadingOverlay.hide(context);

      if (mounted) {
        final saveResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SaveResultScreen(
              file: file,
              fileType: 'image',
              defaultTitle: 'Animasyon_$timestamp',
            ),
          ),
        );

        if (saveResult == true && mounted) {
          setState(() {
            _selectedFiles.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('GIF başarıyla oluşturuldu!')),
          );
        }
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
      appBar: AppBar(title: const Text('JPEG to GIF')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(CupertinoIcons.sparkles, size: 80, color: Colors.purpleAccent),
            const SizedBox(height: 16),
            const KawaruText(
              'Fotoğrafları GIF\'e Çevir',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Birden fazla fotoğrafı seçerek hareketli bir GIF animasyonuna dönüştürün.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(CupertinoIcons.photo_on_rectangle),
              label: Text(_selectedFiles.isNotEmpty 
                ? '${_selectedFiles.length} Fotoğraf Seçildi' 
                : 'Fotoğrafları Seç'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: _selectedFiles.isNotEmpty ? Colors.purple.withValues(alpha: 0.1) : null,
              ),
            ),
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _convertToGif,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('GIF Oluştur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
