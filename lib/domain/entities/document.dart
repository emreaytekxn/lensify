class Document {
  final int? id;
  final String title;
  final int? folderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int pageCount;
  final String? pdfPath;

  Document({
    this.id,
    required this.title,
    this.folderId,
    required this.createdAt,
    required this.updatedAt,
    required this.pageCount,
    this.pdfPath,
  });

  Document copyWith({
    int? id,
    String? title,
    int? folderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? pageCount,
    String? pdfPath,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pageCount: pageCount ?? this.pageCount,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }
}
