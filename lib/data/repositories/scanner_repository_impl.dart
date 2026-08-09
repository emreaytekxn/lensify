import 'package:isar/isar.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/document_page.dart';
import '../../domain/entities/filter_type.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/isar_local_datasource.dart';
import '../models/document_model.dart';
import '../models/folder_model.dart';
import '../models/page_model.dart';
import '../models/batch_item_model.dart';
import '../../domain/entities/batch_item.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  final IsarLocalDataSource dataSource;

  ScannerRepositoryImpl(this.dataSource);

  // --- Mappers ---
  Folder _mapFolderModelToEntity(FolderModel model) {
    return Folder(
      id: model.id,
      name: model.name,
      createdAt: model.createdAt,
      color: model.color,
      isLocked: model.isLocked,
    );
  }

  FolderModel _mapFolderEntityToModel(Folder entity) {
    final model = FolderModel()
      ..name = entity.name
      ..createdAt = entity.createdAt
      ..color = entity.color
      ..isLocked = entity.isLocked;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  Document _mapDocumentModelToEntity(DocumentModel model) {
    return Document(
      id: model.id,
      title: model.title,
      folderId: model.folderId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      pageCount: model.pageCount,
      pdfPath: model.pdfPath,
      tags: model.tags,
      isFavorite: model.isFavorite,
      fileSize: model.fileSize,
      fileType: model.fileType,
    );
  }

  DocumentModel _mapDocumentEntityToModel(Document entity) {
    final model = DocumentModel()
      ..title = entity.title
      ..folderId = entity.folderId
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..pageCount = entity.pageCount
      ..pdfPath = entity.pdfPath
      ..tags = entity.tags
      ..isFavorite = entity.isFavorite
      ..fileSize = entity.fileSize
      ..fileType = entity.fileType;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  DocumentPage _mapPageModelToEntity(PageModel model) {
    return DocumentPage(
      id: model.id,
      documentId: model.documentId,
      originalImagePath: model.originalImagePath,
      processedImagePath: model.processedImagePath,
      pageIndex: model.pageIndex,
      appliedFilter: FilterType.values.firstWhere(
        (e) => e.name == model.appliedFilter,
        orElse: () => FilterType.original,
      ),
      createdAt: model.createdAt,
    );
  }

  PageModel _mapPageEntityToModel(DocumentPage entity) {
    final model = PageModel()
      ..documentId = entity.documentId
      ..originalImagePath = entity.originalImagePath
      ..processedImagePath = entity.processedImagePath
      ..pageIndex = entity.pageIndex
      ..appliedFilter = entity.appliedFilter.name
      ..createdAt = entity.createdAt;
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  // --- Folder Operations ---
  @override
  Future<Folder> createFolder(Folder folder) async {
    final isar = await dataSource.db;
    final model = _mapFolderEntityToModel(folder);
    await isar.writeTxn(() async {
      await isar.folderModels.put(model);
    });
    return _mapFolderModelToEntity(model);
  }

  @override
  Future<List<Folder>> getAllFolders() async {
    final isar = await dataSource.db;
    final models = await isar.folderModels.where().findAll();
    return models.map(_mapFolderModelToEntity).toList();
  }

  @override
  Future<void> updateFolder(Folder folder) async {
    final isar = await dataSource.db;
    final model = _mapFolderEntityToModel(folder);
    await isar.writeTxn(() async {
      await isar.folderModels.put(model);
    });
  }

  @override
  Future<void> deleteFolder(int id) async {
    final isar = await dataSource.db;
    await isar.writeTxn(() async {
      await isar.folderModels.delete(id);
      // Optional: Update documents in this folder to have null folderId
      final docs =
          await isar.documentModels.filter().folderIdEqualTo(id).findAll();
      for (var doc in docs) {
        doc.folderId = null;
        await isar.documentModels.put(doc);
      }
    });
  }

  // --- Document Operations ---
  @override
  Future<Document> createDocument(Document document) async {
    final isar = await dataSource.db;
    final model = _mapDocumentEntityToModel(document);
    await isar.writeTxn(() async {
      await isar.documentModels.put(model);
    });
    return _mapDocumentModelToEntity(model);
  }

  @override
  Future<List<Document>> getAllDocuments() async {
    final isar = await dataSource.db;
    final models =
        await isar.documentModels.where().sortByUpdatedAtDesc().findAll();
    return models.map(_mapDocumentModelToEntity).toList();
  }

  @override
  Future<List<Document>> getDocumentsByFolder(int folderId) async {
    final isar = await dataSource.db;
    final models = await isar.documentModels
        .filter()
        .folderIdEqualTo(folderId)
        .sortByUpdatedAtDesc()
        .findAll();
    return models.map(_mapDocumentModelToEntity).toList();
  }

  @override
  Future<Document?> getDocumentById(int id) async {
    final isar = await dataSource.db;
    final model = await isar.documentModels.get(id);
    if (model == null) return null;
    return _mapDocumentModelToEntity(model);
  }

  @override
  Future<void> updateDocument(Document document) async {
    final isar = await dataSource.db;
    final model = _mapDocumentEntityToModel(document);
    await isar.writeTxn(() async {
      await isar.documentModels.put(model);
    });
  }

  @override
  Future<void> deleteDocument(int id) async {
    final isar = await dataSource.db;
    await isar.writeTxn(() async {
      await isar.documentModels.delete(id);
      // Delete associated pages
      await isar.pageModels.filter().documentIdEqualTo(id).deleteAll();
    });
  }

  @override
  Future<void> moveDocument(int documentId, int? newFolderId) async {
    final isar = await dataSource.db;
    await isar.writeTxn(() async {
      final doc = await isar.documentModels.get(documentId);
      if (doc != null) {
        doc.folderId = newFolderId;
        doc.updatedAt = DateTime.now();
        await isar.documentModels.put(doc);
      }
    });
  }

  // --- Page Operations ---
  @override
  Future<DocumentPage> addPageToDocument(DocumentPage page) async {
    final isar = await dataSource.db;
    final model = _mapPageEntityToModel(page);
    await isar.writeTxn(() async {
      await isar.pageModels.put(model);

      // Update document page count
      final doc = await isar.documentModels.get(page.documentId);
      if (doc != null) {
        doc.pageCount = await isar.pageModels
            .filter()
            .documentIdEqualTo(page.documentId)
            .count();
        doc.updatedAt = DateTime.now();
        await isar.documentModels.put(doc);
      }
    });
    return _mapPageModelToEntity(model);
  }

  @override
  Future<List<DocumentPage>> getPagesForDocument(int documentId) async {
    final isar = await dataSource.db;
    final models = await isar.pageModels
        .filter()
        .documentIdEqualTo(documentId)
        .sortByPageIndex()
        .findAll();
    return models.map(_mapPageModelToEntity).toList();
  }

  @override
  Future<void> updatePage(DocumentPage page) async {
    final isar = await dataSource.db;
    final model = _mapPageEntityToModel(page);
    await isar.writeTxn(() async {
      await isar.pageModels.put(model);
    });
  }

  @override
  Future<void> deletePage(int id) async {
    final isar = await dataSource.db;
    await isar.writeTxn(() async {
      final page = await isar.pageModels.get(id);
      if (page != null) {
        final docId = page.documentId;
        await isar.pageModels.delete(id);

        // Update document page count
        final doc = await isar.documentModels.get(docId);
        if (doc != null) {
          doc.pageCount =
              await isar.pageModels.filter().documentIdEqualTo(docId).count();
          doc.updatedAt = DateTime.now();
          await isar.documentModels.put(doc);
        }
      }
    });
  }

  @override
  Future<void> reorderPages(int documentId, List<DocumentPage> newOrder) async {
    final isar = await dataSource.db;
    await isar.writeTxn(() async {
      for (int i = 0; i < newOrder.length; i++) {
        final page = newOrder[i];
        if (page.id != null) {
          final model = await isar.pageModels.get(page.id!);
          if (model != null) {
            model.pageIndex = i;
            await isar.pageModels.put(model);
          }
        }
      }
    });
  }

  // --- Batch Operations ---
  BatchItem _mapBatchItemModelToEntity(BatchItemModel model) {
    return BatchItem(
      id: model.id,
      sourcePath: model.sourcePath,
      sourceFileName: model.sourceFileName,
      targetFormat: model.targetFormat,
      conversionType: model.conversionType,
      status: model.status,
      progress: model.progress,
      outputPath: model.outputPath,
      errorMessage: model.errorMessage,
      createdAt: model.createdAt,
      completedAt: model.completedAt,
    );
  }

  BatchItemModel _mapBatchItemEntityToModel(BatchItem entity) {
    final model = BatchItemModel()
      ..sourcePath = entity.sourcePath
      ..sourceFileName = entity.sourceFileName
      ..targetFormat = entity.targetFormat
      ..conversionType = entity.conversionType
      ..status = entity.status
      ..progress = entity.progress
      ..outputPath = entity.outputPath
      ..errorMessage = entity.errorMessage
      ..createdAt = entity.createdAt
      ..completedAt = entity.completedAt;
    
    if (entity.id != null) {
      model.id = entity.id!;
    }
    return model;
  }

  @override
  Future<BatchItem> createBatchItem(BatchItem item) async {
    final isar = await dataSource.db;
    final model = _mapBatchItemEntityToModel(item);
    await isar.writeTxn(() async {
      await isar.batchItemModels.put(model);
    });
    return _mapBatchItemModelToEntity(model);
  }

  @override
  Future<List<BatchItem>> getAllBatchItems() async {
    final isar = await dataSource.db;
    final models = await isar.batchItemModels.where().sortByCreatedAtDesc().findAll();
    return models.map(_mapBatchItemModelToEntity).toList();
  }

  @override
  Future<List<BatchItem>> getPendingBatchItems() async {
    final isar = await dataSource.db;
    final models = await isar.batchItemModels
        .filter()
        .statusEqualTo(BatchItemStatus.pending)
        .or()
        .statusEqualTo(BatchItemStatus.converting)
        .sortByCreatedAt()
        .findAll();
    return models.map(_mapBatchItemModelToEntity).toList();
  }

  @override
  Future<void> updateBatchItem(BatchItem item) async {
    final isar = await dataSource.db;
    final model = _mapBatchItemEntityToModel(item);
    await isar.writeTxn(() async {
      await isar.batchItemModels.put(model);
    });
  }

  @override
  Future<void> deleteBatchItem(int id) async {
    final isar = await dataSource.db;
    await isar.writeTxn(() async {
      await isar.batchItemModels.delete(id);
    });
  }

  @override
  Future<void> clearCompletedBatchItems() async {
    final isar = await dataSource.db;
    await isar.writeTxn(() async {
      await isar.batchItemModels
          .filter()
          .statusEqualTo(BatchItemStatus.completed)
          .deleteAll();
    });
  }
}
