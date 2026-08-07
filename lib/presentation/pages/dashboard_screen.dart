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
import '../widgets/loading_overlay.dart';
import 'document_editor_screen.dart';
import 'scanner_camera_screen.dart';
import '../../core/utils/document_import_service.dart';

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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DocumentEditorScreen(document: doc),
                  ),
                );
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DocumentEditorScreen(document: doc),
                  ),
                );
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
}
