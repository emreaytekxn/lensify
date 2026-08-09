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

  // --- Search, Filter & Sort ---
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applySearchFilter();
  }

  void setSmartFolder(SmartFolderType type) {
    state = state.copyWith(activeSmartFolder: type);
    _applySearchFilter();
  }

  void setSortType(SortType type) {
    state = state.copyWith(activeSortType: type);
    _applySearchFilter();
  }

  void _applySearchFilter() {
    List<Document> result = state.allDocuments;
    
    // Filter out ARCHIVED documents unless the active smart folder is 'archive'
    if (state.activeSmartFolder == SmartFolderType.archive) {
      result = result.where((d) => d.tags.contains('ARCHIVED') || d.fileType == 'archive').toList();
    } else {
      result = result.where((d) => !d.tags.contains('ARCHIVED') && d.fileType != 'archive').toList();
    }

    // 1. Apply Smart Folder Filter
    switch (state.activeSmartFolder) {
      case SmartFolderType.recent:
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        result = result.where((d) => d.createdAt.isAfter(sevenDaysAgo)).toList();
        break;
      case SmartFolderType.largeFiles:
        result = result.where((d) => d.fileSize > 20 * 1024 * 1024).toList();
        break;
      case SmartFolderType.favorites:
        result = result.where((d) => d.isFavorite).toList();
        break;
      case SmartFolderType.pdf:
        result = result.where((d) => d.fileType == 'pdf').toList();
        break;
      case SmartFolderType.image:
        result = result.where((d) => d.fileType == 'image').toList();
        break;
      case SmartFolderType.audio:
        result = result.where((d) => d.fileType == 'audio').toList();
        break;
      case SmartFolderType.text:
        result = result.where((d) => d.fileType == 'text').toList();
        break;
      case SmartFolderType.archive:
        // Already handled above
        break;
      case SmartFolderType.none:
        break;
    }

    // 2. Apply Text Search
    if (state.searchQuery.isNotEmpty) {
      final lowerQuery = state.searchQuery.toLowerCase();
      result = result.where((doc) {
        final matchesTitle = doc.title.toLowerCase().contains(lowerQuery);
        final matchesTags = doc.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
        return matchesTitle || matchesTags;
      }).toList();
    }

    // 3. Apply Sort
    switch (state.activeSortType) {
      case SortType.dateDesc:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.dateAsc:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortType.nameAsc:
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortType.nameDesc:
        result.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortType.sizeDesc:
        result.sort((a, b) => b.fileSize.compareTo(a.fileSize));
        break;
    }

    state = state.copyWith(filteredDocuments: result);
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

  Future<void> toggleFavorite(int id) async {
    try {
      final doc = state.allDocuments.firstWhere((d) => d.id == id);
      final updatedDoc = doc.copyWith(
        isFavorite: !doc.isFavorite,
        updatedAt: DateTime.now(),
      );
      await _repository.updateDocument(updatedDoc);
      await loadDocuments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // --- Bulk Selection ---
  void toggleSelectionMode() {
    state = state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedDocumentIds: !state.isSelectionMode
          ? state.selectedDocumentIds
          : {}, // Clear if exiting
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
    final isSelectionMode =
        currentSelection.isNotEmpty || state.isSelectionMode;

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
      for (final id in state.selectedDocumentIds) {
        await _repository.moveDocument(id, newFolderId);
      }
      clearSelection();
      await loadDocuments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleFavoriteSelectedDocuments() async {
    try {
      for (final id in state.selectedDocumentIds) {
        final doc = state.allDocuments.firstWhere((d) => d.id == id);
        final updatedDoc = doc.copyWith(
          isFavorite: !doc.isFavorite,
          updatedAt: DateTime.now(),
        );
        await _repository.updateDocument(updatedDoc);
      }
      clearSelection();
      await loadDocuments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleArchiveSelectedDocuments() async {
    try {
      for (final id in state.selectedDocumentIds) {
        final doc = state.allDocuments.firstWhere((d) => d.id == id);
        
        final hasTag = doc.tags.contains('ARCHIVED');
        final updatedTags = hasTag
            ? doc.tags.where((t) => t != 'ARCHIVED').toList()
            : [...doc.tags, 'ARCHIVED'];

        final updatedDoc = doc.copyWith(
          tags: updatedTags,
          updatedAt: DateTime.now(),
        );
        await _repository.updateDocument(updatedDoc);
      }
      clearSelection();
      await loadDocuments();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final documentNotifierProvider =
    StateNotifierProvider<DocumentNotifier, DocumentState>((ref) {
  final repository = ref.watch(scannerRepositoryProvider);
  return DocumentNotifier(repository, ref);
});
