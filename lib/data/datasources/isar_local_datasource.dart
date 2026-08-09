import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/folder_model.dart';
import '../models/document_model.dart';
import '../models/page_model.dart';
import '../models/batch_item_model.dart';

class IsarLocalDataSource {
  late Future<Isar> db;

  Future<Isar> initDb([String instanceName = 'default']) async {
    final isarInstance = Isar.getInstance(instanceName);
    if (isarInstance != null) {
      db = Future.value(isarInstance);
      return isarInstance;
    }

    final dir = await getApplicationDocumentsDirectory();
    final newDb = await Isar.open(
      [
          FolderModelSchema,
          DocumentModelSchema,
          PageModelSchema,
          BatchItemModelSchema,
      ],
      directory: dir.path,
      name: instanceName,
    );
    db = Future.value(newDb);
    return newDb;
  }
}
