class BatchItem {
  final int? id;
  final String sourcePath;
  final String sourceFileName;
  final String targetFormat;
  final String conversionType;
  final BatchItemStatus status;
  final double progress;
  final String? outputPath;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  BatchItem({
    this.id,
    required this.sourcePath,
    required this.sourceFileName,
    required this.targetFormat,
    required this.conversionType,
    this.status = BatchItemStatus.pending,
    this.progress = 0.0,
    this.outputPath,
    this.errorMessage,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  BatchItem copyWith({
    int? id,
    String? sourcePath,
    String? sourceFileName,
    String? targetFormat,
    String? conversionType,
    BatchItemStatus? status,
    double? progress,
    String? outputPath,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return BatchItem(
      id: id ?? this.id,
      sourcePath: sourcePath ?? this.sourcePath,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      targetFormat: targetFormat ?? this.targetFormat,
      conversionType: conversionType ?? this.conversionType,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      outputPath: outputPath ?? this.outputPath,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

enum BatchItemStatus { pending, converting, completed, failed, paused }
