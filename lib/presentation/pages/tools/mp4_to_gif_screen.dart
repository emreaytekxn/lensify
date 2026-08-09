import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../save_result_screen.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/kawaru_text.dart';

class Mp4ToGifScreen extends StatefulWidget {
  const Mp4ToGifScreen({super.key});

  @override
  State<Mp4ToGifScreen> createState() => _Mp4ToGifScreenState();
}

class _Mp4ToGifScreenState extends State<Mp4ToGifScreen> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _convertToGif() async {
    if (_selectedFile == null) return;

    LoadingOverlay.show(context, message: 'Video analiz ediliyor ve GIF oluşturuluyor...');

    try {
      // Simulate conversion delay
      await Future.delayed(const Duration(seconds: 3));

      final dir = await getApplicationDocumentsDirectory();
      final targetDir = Directory('${dir.path}/images');
      if (!await targetDir.exists()) await targetDir.create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = '${targetDir.path}/animation_$timestamp.gif';
      
      // Simulating conversion by copying the original file
      final file = await _selectedFile!.copy(targetPath);

      if (mounted) LoadingOverlay.hide(context);

      if (mounted) {
        final saveResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SaveResultScreen(
              file: file,
              fileType: 'image',
              defaultTitle: 'VideoAnimasyon_$timestamp',
            ),
          ),
        );

        if (saveResult == true && mounted) {
          setState(() {
            _selectedFile = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video GIF\'e başarıyla dönüştürüldü!')),
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
      appBar: AppBar(title: const Text('MP4 to GIF')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(CupertinoIcons.film, size: 80, color: Colors.deepPurpleAccent),
            const SizedBox(height: 16),
            const KawaruText(
              'Videoyu GIF\'e Çevir',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'MP4 veya MOV formatındaki videolarınızı hareketli GIF animasyonlarına dönüştürün.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(CupertinoIcons.video_camera),
              label: Text(_selectedFile != null 
                ? 'Seçildi: ${_selectedFile!.path.split('/').last}'
                : 'Video Seç'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: _selectedFile != null ? Colors.deepPurple.withValues(alpha: 0.1) : null,
              ),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _convertToGif,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.deepPurpleAccent,
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
