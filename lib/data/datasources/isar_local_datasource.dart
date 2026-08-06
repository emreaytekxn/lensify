import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/folder_model.dart';
import '../models/document_model.dart';
import '../models/page_model.dart';

class IsarLocalDataSource {
  late Future<Isar> db;

  IsarLocalDataSource() {
    db = _initDb();
  }

  Future<Isar> _initDb() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          FolderModelSchema,
          DocumentModelSchema,
          PageModelSchema,
        ],
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
