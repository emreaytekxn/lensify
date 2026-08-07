import '../../domain/entities/folder.dart';

class FolderState {
  final List<Folder> folders;
  final bool isLoading;
  final String? error;
  final int? activeFolderId;

  FolderState({
    this.folders = const [],
    this.isLoading = false,
    this.error,
    this.activeFolderId,
  });

  FolderState copyWith({
    List<Folder>? folders,
    bool? isLoading,
    String? error,
    int? activeFolderId,
    bool clearActiveFolder = false,
  }) {
    return FolderState(
      folders: folders ?? this.folders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      activeFolderId:
          clearActiveFolder ? null : (activeFolderId ?? this.activeFolderId),
    );
  }
}
