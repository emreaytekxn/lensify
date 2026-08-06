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
}
