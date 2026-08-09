import 'package:isar/isar.dart';
import '../../domain/entities/batch_item.dart';

part 'batch_item_model.g.dart';

@collection
class BatchItemModel {
  Id id = Isar.autoIncrement;

  late String sourcePath;
  late String sourceFileName;
  late String targetFormat;
  late String conversionType; // e.g. "media", "transcription", "pdf_to_image", "extract_text"

  @enumerated
  late BatchItemStatus status;

  double progress = 0.0;
  
  String? outputPath;
  String? errorMessage;
  
  late DateTime createdAt;
  DateTime? completedAt;
}
