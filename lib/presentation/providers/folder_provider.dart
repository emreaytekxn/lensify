import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/scanner_repository.dart';
import 'core_providers.dart';
import 'folder_state.dart';

class FolderNotifier extends StateNotifier<FolderState> {
  final ScannerRepository _repository;

  FolderNotifier(this._repository) : super(FolderState()) {
    loadFolders();
  }

  Future<void> loadFolders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final folders = await _repository.getAllFolders();
      state = state.copyWith(folders: folders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createFolder(String name, int color) async {
    try {
      final newFolder = Folder(
        name: name,
        color: color,
        createdAt: DateTime.now(),
      );
      await _repository.createFolder(newFolder);
      await loadFolders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> renameFolder(int id, String newName) async {
    try {
      final folder = state.folders.firstWhere((f) => f.id == id);
      final updatedFolder = folder.copyWith(name: newName);
      await _repository.updateFolder(updatedFolder);
      await loadFolders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> toggleFolderLock(int id) async {
    try {
      final folder = state.folders.firstWhere((f) => f.id == id);
      final updatedFolder = folder.copyWith(isLocked: !folder.isLocked);
      await _repository.updateFolder(updatedFolder);
      await loadFolders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteFolder(int id) async {
    try {
      await _repository.deleteFolder(id);
      
      // If the deleted folder was active, reset active folder
      bool clearActive = state.activeFolderId == id;
      
      await loadFolders();
      
      if (clearActive) {
        state = state.copyWith(clearActiveFolder: true);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setActiveFolder(int? folderId) {
    state = state.copyWith(
      activeFolderId: folderId,
      clearActiveFolder: folderId == null,
    );
  }
}

final folderNotifierProvider = StateNotifierProvider<FolderNotifier, FolderState>((ref) {
  final repository = ref.watch(scannerRepositoryProvider);
  return FolderNotifier(repository);
});
