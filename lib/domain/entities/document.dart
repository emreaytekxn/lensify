class Document {
  final int? id;
  final String title;
  final int? folderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int pageCount;
  final String? pdfPath;
  final List<String> tags;
  final bool isFavorite;
  final int fileSize;
  final String fileType;

  Document({
    this.id,
    required this.title,
    this.folderId,
    required this.createdAt,
    required this.updatedAt,
    required this.pageCount,
    this.pdfPath,
    this.tags = const [],
    this.isFavorite = false,
    this.fileSize = 0,
    this.fileType = 'pdf',
  });

  Document copyWith({
    int? id,
    String? title,
    int? folderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? pageCount,
    String? pdfPath,
    List<String>? tags,
    bool? isFavorite,
    int? fileSize,
    String? fileType,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      folderId: folderId ?? this.folderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pageCount: pageCount ?? this.pageCount,
      pdfPath: pdfPath ?? this.pdfPath,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
    );
  }
}
