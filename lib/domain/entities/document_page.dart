import 'filter_type.dart';

class DocumentPage {
  final int? id;
  final int documentId;
  final String originalImagePath;
  final String? processedImagePath;
  final int pageIndex;
  final FilterType appliedFilter;
  final DateTime createdAt;

  DocumentPage({
    this.id,
    required this.documentId,
    required this.originalImagePath,
    this.processedImagePath,
    required this.pageIndex,
    this.appliedFilter = FilterType.original,
    required this.createdAt,
  });

  DocumentPage copyWith({
    int? id,
    int? documentId,
    String? originalImagePath,
    String? processedImagePath,
    int? pageIndex,
    FilterType? appliedFilter,
    DateTime? createdAt,
  }) {
    return DocumentPage(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      originalImagePath: originalImagePath ?? this.originalImagePath,
      processedImagePath: processedImagePath ?? this.processedImagePath,
      pageIndex: pageIndex ?? this.pageIndex,
      appliedFilter: appliedFilter ?? this.appliedFilter,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
