import '../entities/document.dart';
import '../entities/document_page.dart';
import '../entities/folder.dart';

abstract class ScannerRepository {
  // Folder Operations
  Future<Folder> createFolder(Folder folder);
  Future<List<Folder>> getAllFolders();
  Future<void> updateFolder(Folder folder);
  Future<void> deleteFolder(int id);

  // Document Operations
  Future<Document> createDocument(Document document);
  Future<List<Document>> getAllDocuments();
  Future<List<Document>> getDocumentsByFolder(int folderId);
  Future<Document?> getDocumentById(int id);
  Future<void> updateDocument(Document document);
  Future<void> deleteDocument(int id);
  Future<void> moveDocument(int documentId, int? newFolderId);

  // Page Operations
  Future<DocumentPage> addPageToDocument(DocumentPage page);
  Future<List<DocumentPage>> getPagesForDocument(int documentId);
  Future<void> updatePage(DocumentPage page);
  Future<void> deletePage(int id);
  Future<void> reorderPages(int documentId, List<DocumentPage> newOrder);
}
