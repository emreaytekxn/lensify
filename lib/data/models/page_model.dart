import 'package:isar/isar.dart';

part 'page_model.g.dart';

@collection
class PageModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late int documentId;
  
  late String originalImagePath;
  
  String? processedImagePath;
  
  late int pageIndex;
  
  // Storing enum as String
  late String appliedFilter;
  
  late DateTime createdAt;
}
