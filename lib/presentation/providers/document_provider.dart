import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/scanner_repository.dart';
import 'core_providers.dart';
import 'document_state.dart';
import 'folder_provider.dart';

class DocumentNotifier extends StateNotifier<DocumentState> {
  final ScannerRepository _repository;
  final Ref _ref;

  DocumentNotifier(this._repository, this._ref) : super(DocumentState()) {
    // Listen to active folder changes to reload documents automatically
    _ref.listen<int?>(
      folderNotifierProvider.select((state) => state.activeFolderId),
      (previous, next) {
        loadDocuments();
      },
    );
    
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final activeFolderId = _ref.read(folderNotifierProvider).activeFolderId;
      List<Document> docs;
      
      if (activeFolderId != null) {
        docs = await _repository.getDocumentsByFolder(activeFolderId);
      } else {
        docs = await _repository.getAllDocuments();
      }
      
      state = state.copyWith(
        allDocuments: docs,
        isLoading: false,
      );
      
      _applySearchFilter();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // --- Search ---
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applySearchFilter();
  }

  void _applySearchFilter() {
    if (state.searchQuery.isEmpty) {
      state = state.copyWith(filteredDocuments: state.allDocuments);
    } else {
      final lowerQuery = state.searchQuery.toLowerCase();
      final filtered = state.allDocuments.where((doc) {
        final matchesTitle = doc.title.toLowerCase().contains(lowerQuery);
        final matchesTags = doc.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
        return matchesTitle || matchesTags;
      }).toList();
      state = state.copyWith(filteredDocuments: filtered);
    }
  }

  // --- Document CRUD Operations ---
  Future<void> createDocument(String title, int? folderId) async {
    try {
      final doc = Document(
        title: title,
        folderId: folderId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        pageCount: 0,
      );
      await _repository.createDocument(doc);
      await loadDocuments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteDocument(int id) async {
    try {
      await _repository.deleteDocument(id);
      await loadDocuments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> renameDocument(int id, String newTitle) async {
    try {
      final doc = state.allDocuments.firstWhere((d) => d.id == id);
      final updatedDoc = doc.copyWith(
        title: newTitle,
        updatedAt: DateTime.now(),
      );
      await _repository.updateDocument(updatedDoc);
      await loadDocuments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> moveDocument(int id, int? newFolderId) async {
    try {
      await _repository.moveDocument(id, newFolderId);
      await loadDocuments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addTagToDocument(int id, String tag) async {
    try {
      final doc = state.allDocuments.firstWhere((d) => d.id == id);
      if (!doc.tags.contains(tag)) {
        final updatedDoc = doc.copyWith(
          tags: [...doc.tags, tag],
          updatedAt: DateTime.now(),
        );
        await _repository.updateDocument(updatedDoc);
        await loadDocuments();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeTagFromDocument(int id, String tag) async {
    try {
      final doc = state.allDocuments.firstWhere((d) => d.id == id);
      if (doc.tags.contains(tag)) {
        final updatedTags = doc.tags.where((t) => t != tag).toList();
        final updatedDoc = doc.copyWith(
          tags: updatedTags,
          updatedAt: DateTime.now(),
        );
        await _repository.updateDocument(updatedDoc);
        await loadDocuments();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // --- Bulk Selection ---
  void toggleSelectionMode() {
    state = state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedDocumentIds: !state.isSelectionMode ? state.selectedDocumentIds : {}, // Clear if exiting
    );
  }

  void toggleDocumentSelection(int id) {
    final currentSelection = Set<int>.from(state.selectedDocumentIds);
    if (currentSelection.contains(id)) {
      currentSelection.remove(id);
    } else {
      currentSelection.add(id);
    }
    
    // Auto-exit selection mode if no items selected
    final isSelectionMode = currentSelection.isNotEmpty || state.isSelectionMode;
    
    state = state.copyWith(
      selectedDocumentIds: currentSelection,
      isSelectionMode: isSelectionMode,
    );
  }

  void selectAll() {
    final allIds = state.filteredDocuments.map((d) => d.id!).toSet();
    state = state.copyWith(selectedDocumentIds: allIds);
  }

  void clearSelection() {
    state = state.copyWith(
      selectedDocumentIds: {},
      isSelectionMode: false,
    );
  }

  Future<void> deleteSelectedDocuments() async {
    try {
      state = state.copyWith(isLoading: true);
      for (final id in state.selectedDocumentIds) {
        await _repository.deleteDocument(id);
      }
      clearSelection();
      await loadDocuments();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> moveSelectedDocuments(int? newFolderId) async {
    try {
      state = state.copyWith(isLoading: true);
      for (final id in state.selectedDocumentIds) {
        await _repository.moveDocument(id, newFolderId);
      }
      clearSelection();
      await loadDocuments();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final documentNotifierProvider = StateNotifierProvider<DocumentNotifier, DocumentState>((ref) {
  final repository = ref.watch(scannerRepositoryProvider);
  return DocumentNotifier(repository, ref);
});
