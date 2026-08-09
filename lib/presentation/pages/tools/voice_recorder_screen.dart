import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../domain/entities/document.dart';
import '../../providers/core_providers.dart';
import '../../providers/document_provider.dart';
import '../../providers/folder_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../../core/utils/media_conversion_service.dart';
import '../../../core/utils/transcription_service.dart';
import '../../../l10n/app_localizations.dart';

class VoiceRecorderScreen extends ConsumerStatefulWidget {
  const VoiceRecorderScreen({super.key});

  @override
  ConsumerState<VoiceRecorderScreen> createState() => _VoiceRecorderScreenState();
}

class _VoiceRecorderScreenState extends ConsumerState<VoiceRecorderScreen>
    with SingleTickerProviderStateMixin {
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String? _recordedFilePath;
  Timer? _timer;
  int _recordDuration = 0;
  bool _isCancelled = false;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  String get _formattedTime {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_recordDuration ~/ 60);
    final seconds = twoDigits(_recordDuration % 60);
    return "$minutes:$seconds";
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final audioDir = Directory('${dir.path}/audio_docs');
        if (!await audioDir.exists()) await audioDir.create(recursive: true);
        
        final path = '${audioDir.path}/rec_$timestamp.m4a';

        await _audioRecorder.start(
          const RecordConfig(),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordDuration = 0;
          _recordedFilePath = null;
        });
        _startTimer();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mikrofon izni reddedildi!')),
          );
        }
      }
    } catch (e) {
      debugPrint("Kayıt hatası: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      _timer?.cancel();
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
      });

      if (path != null) {
        // Save to Database
        final activeFolderId = ref.read(folderNotifierProvider).activeFolderId;
        final repo = ref.read(scannerRepositoryProvider);
        final file = File(path);

        final doc = Document(
          title: 'Ses Kaydı - ${_formattedTime}',
          folderId: activeFolderId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          pageCount: 0,
          pdfPath: path,
          isFavorite: false,
          fileSize: await file.length(),
          fileType: 'audio',
        );

        await repo.createDocument(doc);
        await ref.read(documentNotifierProvider.notifier).loadDocuments();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ses kaydı belgelere eklendi.')),
          );
        }
      }
    } catch (e) {
      debugPrint("Durdurma hatası: $e");
    }
  }

  Future<void> _transcribeAudio() async {
    if (_recordedFilePath == null) return;
    
    _isCancelled = false;

    LoadingOverlay.show(
      context,
      message: 'Sesten metne dönüştürülüyor...\nBu işlem uzun sürebilir.',
      showTimer: true,
      infoText: 'İşlem tamamen cihazınızda (çevrimdışı) gerçekleşmektedir.',
      onCancel: () {
        _isCancelled = true;
        LoadingOverlay.hide(context);
      },
    );

    try {
      // 1. Convert any media to 16kHz WAV for Whisper
      final wavPath = await MediaConversionService.convertMedia(_recordedFilePath!, 'wav');
      if (_isCancelled) return;

      if (wavPath == null) {
        if (mounted) LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medya dönüştürme başarısız.')),
        );
        return;
      }

      // 2. Transcribe the WAV file
      final text = await TranscriptionService.transcribeAudio(
        wavPath,
        isCancelled: () => _isCancelled,
      );

      if (_isCancelled) return;
      if (mounted) LoadingOverlay.hide(context);

      if (text != null && text.isNotEmpty) {
        // Save text to Document
        final dir = await getApplicationDocumentsDirectory();
        final textDir = Directory('${dir.path}/text_docs');
        if (!await textDir.exists()) await textDir.create(recursive: true);
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${textDir.path}/transcription_$timestamp.txt');
        await file.writeAsString(text);

        final activeFolderId = ref.read(folderNotifierProvider).activeFolderId;
        final repo = ref.read(scannerRepositoryProvider);
        
        final doc = Document(
          title: 'Çevrilen Metin (Kayıt)',
          folderId: activeFolderId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          pageCount: 0,
          pdfPath: file.path,
          isFavorite: false,
          fileSize: await file.length(),
          fileType: 'text',
        );
        
        await repo.createDocument(doc);
        await ref.read(documentNotifierProvider.notifier).loadDocuments();

        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Çeviri Başarılı!'),
              content: SingleChildScrollView(child: Text(text)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Kapat'),
                ),
              ],
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ses algılanamadı veya işlem başarısız.')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akıllı Diktafon')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isRecording)
                      FadeTransition(
                        opacity: _pulseController,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.redAccent.withValues(alpha: 0.2),
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.mic_fill,
                              color: Colors.redAccent,
                              size: 80,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.mic,
                            color: Theme.of(context).primaryColor,
                            size: 80,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w200,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isRecording ? 'Kaydediliyor...' : 'Kayıt Yapılmıyor',
                      style: TextStyle(
                        color: _isRecording ? Colors.redAccent : Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isRecording ? _stopRecording : _startRecording,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isRecording ? Colors.redAccent : Theme.of(context).primaryColor,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isRecording ? 30 : 60,
                          height: _isRecording ? 30 : 60,
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.redAccent : Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(_isRecording ? 8 : 40),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!_isRecording && _recordedFilePath != null) ...[
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _transcribeAudio,
                      icon: const Icon(CupertinoIcons.text_quote),
                      label: const Text('Metne Çevir (Yapay Zeka)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
