import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/document.dart';
import '../providers/core_providers.dart';
import '../providers/document_provider.dart';
import '../providers/folder_provider.dart';
import '../widgets/loading_overlay.dart';
import 'package:path/path.dart' as p;

class SaveResultScreen extends ConsumerStatefulWidget {
  final File file;
  final String fileType;
  final String defaultTitle;
  final int pageCount;
  
  const SaveResultScreen({
    super.key,
    required this.file,
    required this.fileType,
    required this.defaultTitle,
    this.pageCount = 0,
  });

  @override
  ConsumerState<SaveResultScreen> createState() => _SaveResultScreenState();
}

class _SaveResultScreenState extends ConsumerState<SaveResultScreen> {
  late TextEditingController _titleController;
  int? _selectedFolderId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.defaultTitle);
    _selectedFolderId = ref.read(folderNotifierProvider).activeFolderId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir isim girin.')),
      );
      return;
    }

    LoadingOverlay.show(context, message: 'Kaydediliyor...');
    try {
      final repo = ref.read(scannerRepositoryProvider);
      final fileSize = await widget.file.length();

      final doc = Document(
        title: title,
        folderId: _selectedFolderId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        pageCount: widget.pageCount,
        pdfPath: widget.file.path,
        fileType: widget.fileType,
        fileSize: fileSize,
      );

      await repo.createDocument(doc);
      await ref.read(documentNotifierProvider.notifier).loadDocuments();

      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dosya kasaya başarıyla kaydedildi!')),
        );
        // Pop twice to return to tools menu, wait, just popping until ToolsScreen might be hard. 
        // We'll pop SaveResultScreen and let the caller pop its own screen, or we can use popUntil.
        Navigator.of(context).pop(true); // Return true indicating success
      }
    } catch (e) {
      if (mounted) {
        LoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaydetme hatası: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final folders = ref.watch(folderNotifierProvider).folders;
    final ext = p.extension(widget.file.path).toUpperCase().replaceAll('.', '');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosyayı Kaydet'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.fileType == 'pdf'
                          ? CupertinoIcons.doc_fill
                          : widget.fileType == 'image'
                              ? CupertinoIcons.photo_fill
                              : widget.fileType == 'audio'
                                  ? CupertinoIcons.waveform_path_badge_plus
                                  : CupertinoIcons.doc_text_fill,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$ext Formatında Hazır',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Dosya Adı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Örn: Kimlik Fotokopisi',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Hedef Klasör', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: _selectedFolderId,
                  isExpanded: true,
                  hint: const Text('Ana Dizin (Klasörsüz)'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Ana Dizin (Klasörsüz)'),
                    ),
                    ...folders.map((folder) {
                      return DropdownMenuItem(
                        value: folder.id,
                        child: Text(folder.name),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedFolderId = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Kasaya Kaydet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
