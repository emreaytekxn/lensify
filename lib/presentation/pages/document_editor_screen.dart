import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/pdf_generation_service.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/document_page.dart';
import '../providers/core_providers.dart';
import '../providers/document_provider.dart';
import 'scanner_camera_screen.dart';
import '../../core/utils/ocr_service.dart';
import '../../core/utils/tts_service.dart';
import 'package:flutter/services.dart';
import 'signature_studio_screen.dart';
import '../../core/utils/image_filter_service.dart';
import '../../domain/entities/filter_type.dart';

class DocumentEditorScreen extends ConsumerStatefulWidget {
  final Document document;

  const DocumentEditorScreen({super.key, required this.document});

  @override
  ConsumerState<DocumentEditorScreen> createState() =>
      _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends ConsumerState<DocumentEditorScreen> {
  List<DocumentPage> _pages = [];
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    try {
      final repo = ref.read(scannerRepositoryProvider);
      final pages = await repo.getPagesForDocument(widget.document.id!);
      if (mounted) {
        setState(() {
          _pages = pages;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading pages: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deletePage(DocumentPage page) async {
    try {
      final repo = ref.read(scannerRepositoryProvider);
      await repo.deletePage(page.id!);

      // Remove files from disk (optional but good for cleanup)
      if (page.processedImagePath != null) {
        final f = File(page.processedImagePath!);
        if (await f.exists()) await f.delete();
      }
      final orig = File(page.originalImagePath);
      if (await orig.exists()) await orig.delete();

      ref.read(documentNotifierProvider.notifier).loadDocuments();
      await _loadPages();
    } catch (e) {
      debugPrint("Delete page error: $e");
    }
  }

  Future<void> _reorderPages(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final item = _pages.removeAt(oldIndex);
      _pages.insert(newIndex, item);
    });

    try {
      final repo = ref.read(scannerRepositoryProvider);
      await repo.reorderPages(widget.document.id!, _pages);
    } catch (e) {
      debugPrint("Reorder error: $e");
    }
  }

  Future<void> _sharePdf() async {
    if (_pages.isEmpty) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final sanitizedTitle = widget.document.title.replaceAll(' ', '_');
      final outPath = '${tempDir.path}/$sanitizedTitle.pdf';

      final imagePaths = _pages
          .map((p) => p.processedImagePath ?? p.originalImagePath)
          .toList();

      final pdfFile =
          await PdfGenerationService.generatePdf(imagePaths, outPath);

      // Update DB with latest PDF path
      final repo = ref.read(scannerRepositoryProvider);
      final updatedDoc = widget.document.copyWith(pdfPath: pdfFile.path);
      await repo.updateDocument(updatedDoc);
      await ref.read(documentNotifierProvider.notifier).loadDocuments();

      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: widget.document.title,
        sharePositionOrigin: Rect.fromLTWH(0, 0, size.width, size.height / 2),
      );
    } catch (e) {
      debugPrint("PDF Export Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _extractTextFromPage(DocumentPage page) async {
    final imagePath = page.processedImagePath ?? page.originalImagePath;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CupertinoActivityIndicator()),
    );

    final text = await OcrService.extractText(imagePath);

    if (mounted) {
      Navigator.pop(context); // close dialog
      _showOcrResult(text);
    }
  }

  void _openSignatureStudio(DocumentPage page) async {
    final imagePath = page.processedImagePath ?? page.originalImagePath;
    final success = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SignatureStudioScreen(imagePath: imagePath),
      ),
    );

    if (success == true) {
      // Refresh the list to show the new image with the signature
      await _loadPages();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İmza başarıyla eklendi!')));
    }
  }

  void _showOcrResult(String text) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        bool isPlaying = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SafeArea(
                  child: Column(
                    children: [
                      AppBar(
                        title: const Text('Metin Çıkarımı (OCR)'),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            TTSService.stop();
                            Navigator.pop(context);
                          },
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(CupertinoIcons.doc_on_clipboard),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Metin panoya kopyalandı!')));
                            },
                          ),
                          IconButton(
                            icon: Icon(isPlaying
                                ? CupertinoIcons.speaker_3_fill
                                : CupertinoIcons.speaker_2),
                            color: isPlaying ? Colors.blue : null,
                            onPressed: () async {
                              if (isPlaying) {
                                await TTSService.stop();
                                setState(() => isPlaying = false);
                              } else {
                                setState(() => isPlaying = true);
                                await TTSService.speak(text);
                                // It won't auto-stop icon without a listener, but we can just let it be playing or user can tap again to stop.
                              }
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16.0),
                          child: SelectableText(
                            text.isEmpty
                                ? "Bu sayfada okunabilir bir metin bulunamadı."
                                : text,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _openCamera() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ScannerCameraScreen(targetDocumentId: widget.document.id),
      ),
    );
    // Reload pages when coming back from camera
    _loadPages();
  }

  void _showFilterOptions(DocumentPage page) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Filtre Seç',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: FilterType.values.map((filter) {
                  return ActionChip(
                    label: Text(filter.name),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _applyFilter(page, filter);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _applyFilter(DocumentPage page, FilterType filter) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CupertinoActivityIndicator()),
    );
    try {
      final originalPath = page.originalImagePath;
      final newPath =
          await ImageFilterService.applyFilter(originalPath, filter);

      final updatedPage = page.copyWith(
        processedImagePath: newPath,
        appliedFilter: filter,
      );

      final repo = ref.read(scannerRepositoryProvider);
      await repo.updatePage(updatedPage);
      await _loadPages();
    } catch (e) {
      debugPrint("Filter Error: $e");
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.title),
        actions: [
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CupertinoActivityIndicator(),
            )
          else
            TextButton.icon(
              onPressed: _pages.isEmpty ? null : _sharePdf,
              icon: const Icon(CupertinoIcons.share),
              label: const Text('Paylaş'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _pages.isEmpty
              ? const Center(child: Text("Bu belgede hiç sayfa yok."))
              : ReorderableListView.builder(
                  padding:
                      const EdgeInsets.only(bottom: 100), // padding for FAB
                  itemCount: _pages.length,
                  onReorder: _reorderPages,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    final imagePath =
                        page.processedImagePath ?? page.originalImagePath;

                    return Card(
                      key: ValueKey(
                          page.id ?? index), // Critical for ReorderableListView
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(imagePath),
                            width: 60,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text('Sayfa ${index + 1}'),
                        subtitle: Text(page.appliedFilter.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(CupertinoIcons.pen,
                                  color: Colors.purple),
                              onPressed: () => _openSignatureStudio(page),
                            ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.color_filter,
                                  color: Colors.orange),
                              onPressed: () => _showFilterOptions(page),
                            ),
                            IconButton(
                              icon: const Icon(Icons.text_snippet,
                                  color: Colors.blue),
                              onPressed: () => _extractTextFromPage(page),
                            ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.trash,
                                  color: Colors.redAccent),
                              onPressed: () => _deletePage(page),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCamera,
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(CupertinoIcons.plus, color: Colors.white),
        label: const Text(
          'Sayfa Ekle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
