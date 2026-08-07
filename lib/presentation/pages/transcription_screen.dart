import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/media_conversion_service.dart';
import '../../core/utils/transcription_service.dart';
import '../widgets/loading_overlay.dart';
import 'package:path_provider/path_provider.dart';

class TranscriptionScreen extends StatefulWidget {
  const TranscriptionScreen({super.key});

  @override
  State<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  String? _selectedFilePath;
  String? _selectedFileName;
  String? _transcribedText;
  bool _isCancelled = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType
          .video, // or audio, but file_picker doesn't do both well in cross-platform without custom ext.
      // So we use media
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
        _transcribedText = null;
      });
    }
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'flac'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
        _transcribedText = null;
      });
    }
  }

  Future<void> _transcribe() async {
    if (_selectedFilePath == null) return;

    _isCancelled = false;

    LoadingOverlay.show(context,
        message: 'Yapay Zeka Sesi Analiz Ediyor...\nBu işlem uzun sürebilir.',
        showTimer: true,
        infoText:
            'İşlem tamamen cihazınızda (çevrimdışı) gerçekleşmektedir.\nSes uzunluğuna bağlı olarak dakikalarca sürebilir.',
        onCancel: () {
      _isCancelled = true;
      LoadingOverlay.hide(context);
    });

    try {
      // 1. Convert any media to 16kHz WAV for Whisper
      final wavPath =
          await MediaConversionService.convertMedia(_selectedFilePath!, 'wav');

      if (_isCancelled) return;

      if (wavPath == null) {
        if (mounted) LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medya dönüştürme başarısız.')),
        );
        return;
      }

      // 2. Transcribe the WAV file
      final text = await TranscriptionService.transcribeAudio(wavPath);

      if (_isCancelled) return;

      if (mounted) LoadingOverlay.hide(context);

      if (text != null && text.isNotEmpty) {
        setState(() {
          _transcribedText = text;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ses algılanamadı veya işlem başarısız.')),
        );
      }
    } catch (e) {
      if (_isCancelled) return;
      if (mounted) LoadingOverlay.hide(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _copyToClipboard() {
    if (_transcribedText == null) return;
    Clipboard.setData(ClipboardData(text: _transcribedText!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Metin panoya kopyalandı!')),
    );
  }

  Future<void> _exportAsTxt() async {
    if (_transcribedText == null) return;
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/transcription_kawaru.txt';
      final file = File(path);
      await file.writeAsString(_transcribedText!);

      await Share.shareXFiles(
        [XFile(path)],
        text: 'Kawaru ile çıkarılan metin',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dışa aktarma hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yapay Zeka Transkripsiyon'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(CupertinoIcons.waveform_path_badge_plus,
                size: 80, color: Colors.blueAccent),
            const SizedBox(height: 16),
            const Text(
              'Sesi Yazıya Çevir',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Videolardaki veya ses kayıtlarındaki konuşmaları tamamen internetsiz olarak metne çevirin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(CupertinoIcons.video_camera),
                    label: const Text('Video Seç'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickAudioFile,
                    icon: const Icon(CupertinoIcons.music_note),
                    label: const Text('Ses Seç'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedFileName != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Seçilen Dosya: $_selectedFileName',
                    textAlign: TextAlign.center),
              ),
            const SizedBox(height: 24),
            if (_selectedFilePath != null)
              ElevatedButton(
                onPressed: _transcribe,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Yazıya Çevir',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            if (_transcribedText != null) ...[
              const SizedBox(height: 40),
              const Text('Sonuç:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Text(_transcribedText!),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(CupertinoIcons.doc_on_clipboard),
                    label: const Text('Kopyala'),
                  ),
                  TextButton.icon(
                    onPressed: _exportAsTxt,
                    icon: const Icon(CupertinoIcons.share),
                    label: const Text('TXT Paylaş'),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
