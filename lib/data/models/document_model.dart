import 'package:isar/isar.dart';

part 'document_model.g.dart';

@collection
class DocumentModel {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String title;

  @Index()
  int? folderId;

  late DateTime createdAt;

  late DateTime updatedAt;

  late int pageCount;

  String? pdfPath;

  List<String> tags = [];

  bool isFavorite = false;
  
  int fileSize = 0; // bytes
  
  String fileType = 'pdf'; // 'pdf', 'image', 'audio', 'text'
}
