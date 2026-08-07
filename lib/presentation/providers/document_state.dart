import '../../domain/entities/document.dart';

class DocumentState {
  final List<Document> allDocuments;
  final List<Document> filteredDocuments;
  final bool isLoading;
  final String? error;

  // Search & Filter
  final String searchQuery;

  // Bulk Selection
  final Set<int> selectedDocumentIds;
  final bool isSelectionMode;

  DocumentState({
    this.allDocuments = const [],
    this.filteredDocuments = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedDocumentIds = const {},
    this.isSelectionMode = false,
  });

  DocumentState copyWith({
    List<Document>? allDocuments,
    List<Document>? filteredDocuments,
    bool? isLoading,
    String? error,
    String? searchQuery,
    Set<int>? selectedDocumentIds,
    bool? isSelectionMode,
  }) {
    return DocumentState(
      allDocuments: allDocuments ?? this.allDocuments,
      filteredDocuments: filteredDocuments ?? this.filteredDocuments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDocumentIds: selectedDocumentIds ?? this.selectedDocumentIds,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }
}
