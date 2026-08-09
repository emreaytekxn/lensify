import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/document_provider.dart';
import '../providers/document_state.dart';
import '../providers/folder_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/core_providers.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/document_grid_card.dart';
import '../widgets/document_list_card.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/folder_list_view.dart';
import '../widgets/smart_folder_list_view.dart';
import '../widgets/loading_overlay.dart';
import 'document_editor_screen.dart';
import 'scanner_camera_screen.dart';
import 'viewers/pdf_viewer_screen.dart';
import 'viewers/audio_player_screen.dart';
import 'viewers/image_viewer_screen.dart';
import 'viewers/text_viewer_screen.dart';
import 'dart:io';
import '../../core/utils/document_import_service.dart';
import '../../core/utils/archive_service.dart';
import '../../domain/entities/document.dart';
import 'package:path/path.dart' as p;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docState = ref.watch(documentNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: const DashboardAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const SmartFolderListView(),
          const SizedBox(height: 16),
          _buildSortHeader(context, ref, docState),
          const FolderListView(),
          const SizedBox(height: 16),
          Expanded(
            child: docState.isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : docState.filteredDocuments.isEmpty
                    ? const EmptyStateView()
                    : _buildDocumentView(
                        context, ref, docState, settings.isGridView),
          ),
        ],
      ),
      floatingActionButton: docState.isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddOptions(context, ref),
              backgroundColor: Theme.of(context).primaryColor,
              icon: const Icon(CupertinoIcons.plus, color: Colors.white),
              label: const Text(
                'Yeni Belge',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
    );
  }

  Widget _buildDocumentView(
    BuildContext context,
    WidgetRef ref,
    DocumentState state,
    bool isGridView,
  ) {
    if (isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: state.filteredDocuments.length,
        itemBuilder: (context, index) {
          final doc = state.filteredDocuments[index];
          final isSelected = state.selectedDocumentIds.contains(doc.id);

          return DocumentGridCard(
            document: doc,
            isSelected: isSelected,
            isSelectionMode: state.isSelectionMode,
            onTap: () {
              if (state.isSelectionMode) {
                ref
                    .read(documentNotifierProvider.notifier)
                    .toggleDocumentSelection(doc.id!);
              } else {
                _navigateToViewer(context, ref, doc);
              }
            },
            onLongPress: () {
              ref.read(documentNotifierProvider.notifier).toggleSelectionMode();
              ref
                  .read(documentNotifierProvider.notifier)
                  .toggleDocumentSelection(doc.id!);
            },
          );
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
        itemCount: state.filteredDocuments.length,
        itemBuilder: (context, index) {
          final doc = state.filteredDocuments[index];
          final isSelected = state.selectedDocumentIds.contains(doc.id);

          return DocumentListCard(
            document: doc,
            isSelected: isSelected,
            isSelectionMode: state.isSelectionMode,
            onTap: () {
              if (state.isSelectionMode) {
                ref
                    .read(documentNotifierProvider.notifier)
                    .toggleDocumentSelection(doc.id!);
              } else {
                _navigateToViewer(context, ref, doc);
              }
            },
            onLongPress: () {
              ref.read(documentNotifierProvider.notifier).toggleSelectionMode();
              ref
                  .read(documentNotifierProvider.notifier)
                  .toggleDocumentSelection(doc.id!);
            },
          );
        },
      );
    }
  }

  void _navigateToViewer(BuildContext context, WidgetRef ref, document) {
    if (document.pdfPath != null) {
      if (document.fileType == 'audio') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AudioPlayerScreen(
              audioPath: document.pdfPath!,
              title: document.title,
            ),
          ),
        );
        return;
      } else if (document.fileType == 'image') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImageViewerScreen(
              imagePath: document.pdfPath!,
              title: document.title,
            ),
          ),
        );
        return;
      } else if (document.fileType == 'text') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TextViewerScreen(
              textPath: document.pdfPath!,
              title: document.title,
            ),
          ),
        );
        return;
      } else if (document.fileType == 'pdf') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(
              pdfPath: document.pdfPath!,
              title: document.title,
            ),
          ),
        );
        return;
      } else if (document.fileType == 'archive') {
        _unzipDocument(context, ref, document);
        return;
      }
    }
    
    // Default fallback for scanned documents
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentEditorScreen(document: document),
      ),
    );
  }

  Future<void> _unzipDocument(BuildContext context, WidgetRef ref, Document document) async {
    LoadingOverlay.show(context, message: 'Arşivden çıkarılıyor...');
    try {
      final extractedPaths = await ArchiveService.unzipFile(document.pdfPath!);
      if (extractedPaths.isNotEmpty) {
        final folderId = document.folderId;
        final repo = ref.read(scannerRepositoryProvider);
        
        for (var path in extractedPaths) {
          final file = File(path);
          if (await file.exists()) {
            final ext = p.extension(path).toLowerCase();
            String fileType = 'image'; // default
            if (ext == '.pdf') fileType = 'pdf';
            if (ext == '.txt') fileType = 'text';
            if (ext == '.wav' || ext == '.mp3' || ext == '.m4a') fileType = 'audio';

            final newDoc = Document(
              title: p.basename(path),
              folderId: folderId,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              pageCount: 0,
              pdfPath: path,
              isFavorite: false,
              fileSize: await file.length(),
              fileType: fileType,
            );
            await repo.createDocument(newDoc);
          }
        }
        await ref.read(documentNotifierProvider.notifier).loadDocuments();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${extractedPaths.length} dosya çıkarıldı.')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Arşiv boş veya bozuk.')),
          );
        }
      }
    } finally {
      if (context.mounted) LoadingOverlay.hide(context);
    }
  }

  void _showAddOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Yeni Belge Oluştur',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.camera, color: Colors.blue),
                title: const Text('Kamera ile Tara'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ScannerCameraScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.photo, color: Colors.purple),
                title: const Text('Galeriden Resim Aktar'),
                onTap: () async {
                  Navigator.pop(context);
                  LoadingOverlay.show(context, message: 'İçe aktarılıyor...');
                  try {
                    final folderId =
                        ref.read(folderNotifierProvider).activeFolderId;
                    final repo = ref.read(scannerRepositoryProvider);
                    await DocumentImportService(repo)
                        .importFromGallery(folderId);
                    ref.read(documentNotifierProvider.notifier).loadDocuments();
                  } finally {
                    if (context.mounted) LoadingOverlay.hide(context);
                  }
                },
              ),
              ListTile(
                leading:
                    const Icon(CupertinoIcons.doc_text, color: Colors.orange),
                title: const Text('PDF İçe Aktar'),
                subtitle: const Text('PDF sayfaları resme dönüştürülür'),
                onTap: () async {
                  Navigator.pop(context);
                  LoadingOverlay.show(context,
                      message: 'PDF dönüştürülüyor...');
                  try {
                    final folderId =
                        ref.read(folderNotifierProvider).activeFolderId;
                    final repo = ref.read(scannerRepositoryProvider);
                    await DocumentImportService(repo).importPdf(folderId);
                    ref.read(documentNotifierProvider.notifier).loadDocuments();
                  } finally {
                    if (context.mounted) LoadingOverlay.hide(context);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortHeader(BuildContext context, WidgetRef ref, DocumentState docState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Dosyalarınız',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          PopupMenuButton<SortType>(
            icon: const Icon(CupertinoIcons.sort_down, size: 20),
            onSelected: (type) {
              ref.read(documentNotifierProvider.notifier).setSortType(type);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortType.dateDesc,
                child: Text('En Yeniler'),
              ),
              const PopupMenuItem(
                value: SortType.dateAsc,
                child: Text('En Eskiler'),
              ),
              const PopupMenuItem(
                value: SortType.sizeDesc,
                child: Text('Boyuta Göre (Büyük > Küçük)'),
              ),
              const PopupMenuItem(
                value: SortType.nameAsc,
                child: Text('İsme Göre (A-Z)'),
              ),
              const PopupMenuItem(
                value: SortType.nameDesc,
                child: Text('İsme Göre (Z-A)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
