import '../../domain/entities/document.dart';

enum SmartFolderType {
  none,
  recent, // Last 7 days
  largeFiles, // > 20 MB
  favorites,
  pdf,
  image,
  audio,
  text,
  archive
}

enum SortType {
  dateDesc,
  dateAsc,
  nameAsc,
  nameDesc,
  sizeDesc,
}

class DocumentState {
  final List<Document> allDocuments;
  final List<Document> filteredDocuments;
  final bool isLoading;
  final String? error;

  // Search & Filter
  final String searchQuery;
  final SmartFolderType activeSmartFolder;
  final SortType activeSortType;

  // Bulk Selection
  final Set<int> selectedDocumentIds;
  final bool isSelectionMode;

  DocumentState({
    this.allDocuments = const [],
    this.filteredDocuments = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.activeSmartFolder = SmartFolderType.none,
    this.activeSortType = SortType.dateDesc,
    this.selectedDocumentIds = const {},
    this.isSelectionMode = false,
  });

  DocumentState copyWith({
    List<Document>? allDocuments,
    List<Document>? filteredDocuments,
    bool? isLoading,
    String? error,
    String? searchQuery,
    SmartFolderType? activeSmartFolder,
    SortType? activeSortType,
    Set<int>? selectedDocumentIds,
    bool? isSelectionMode,
  }) {
    return DocumentState(
      allDocuments: allDocuments ?? this.allDocuments,
      filteredDocuments: filteredDocuments ?? this.filteredDocuments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      activeSmartFolder: activeSmartFolder ?? this.activeSmartFolder,
      activeSortType: activeSortType ?? this.activeSortType,
      selectedDocumentIds: selectedDocumentIds ?? this.selectedDocumentIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }
}
