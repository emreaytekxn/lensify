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
  final File? file;
  final String fileType;
  final String defaultTitle;
  final int pageCount;
  final Document? existingDocument;
  
  const SaveResultScreen({
    super.key,
    this.file,
    required this.fileType,
    required this.defaultTitle,
    this.pageCount = 0,
    this.existingDocument,
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
      if (widget.existingDocument != null) {
        final doc = Document(
          id: widget.existingDocument!.id,
          title: title,
          folderId: _selectedFolderId,
          createdAt: widget.existingDocument!.createdAt,
          updatedAt: DateTime.now(),
          pageCount: widget.existingDocument!.pageCount,
          pdfPath: widget.existingDocument!.pdfPath,
          tags: widget.existingDocument!.tags,
          isFavorite: widget.existingDocument!.isFavorite,
          fileSize: widget.existingDocument!.fileSize,
          fileType: widget.existingDocument!.fileType,
        );
        await repo.updateDocument(doc);
      } else {
        final fileSize = await widget.file!.length();

        final doc = Document(
          title: title,
          folderId: _selectedFolderId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          pageCount: widget.pageCount,
          pdfPath: widget.file!.path,
          fileType: widget.fileType,
          fileSize: fileSize,
        );

        await repo.createDocument(doc);
      }
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
    final ext = widget.file != null 
        ? p.extension(widget.file!.path).toUpperCase().replaceAll('.', '') 
        : widget.fileType.toUpperCase();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Dosyayı Kaydet', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Premium Header Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withValues(alpha: 0.7)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.fileType == 'pdf'
                                  ? CupertinoIcons.doc_fill
                                  : widget.fileType == 'archive'
                                      ? CupertinoIcons.archivebox_fill
                                      : widget.fileType == 'image'
                                          ? CupertinoIcons.photo_fill
                                          : widget.fileType == 'audio'
                                              ? CupertinoIcons.waveform_path_badge_plus
                                              : CupertinoIcons.doc_text_fill,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$ext Formatında Hazır',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'İşlem başarıyla tamamlandı. Dosyanızı kasanıza kaydedebilirsiniz.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Inputs Section
                    const Text('Dosya Adı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Örn: Önemli Belge',
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        prefixIcon: const Icon(CupertinoIcons.pen, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Text('Hedef Klasör', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: _selectedFolderId,
                          isExpanded: true,
                          icon: const Icon(CupertinoIcons.chevron_down, color: Colors.grey),
                          hint: const Text('Ana Dizin (Klasörsüz)'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.tray, size: 20, color: Colors.grey),
                                  SizedBox(width: 12),
                                  Text('Ana Dizin (Klasörsüz)', style: TextStyle(fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            ...folders.map((folder) {
                              return DropdownMenuItem(
                                value: folder.id,
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.folder_fill, size: 20, color: Color(folder.color)),
                                    const SizedBox(width: 12),
                                    Text(folder.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  ],
                                ),
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
                  ],
                ),
              ),
            ),
            
            // Bottom Save Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.check_mark_circled_solid, size: 24),
                    SizedBox(width: 12),
                    Text('Kasaya Kaydet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
