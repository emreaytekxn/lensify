import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/document_provider.dart';
import '../providers/document_state.dart';
import '../providers/settings_provider.dart';
import '../providers/folder_provider.dart';
import '../providers/core_providers.dart';
import '../pages/settings_screen.dart';
import '../widgets/loading_overlay.dart';
import '../../core/utils/archive_service.dart';
import '../../domain/entities/document.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/ux_feedback.dart';

class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docState = ref.watch(documentNotifierProvider);
    final isSelectionMode = docState.isSelectionMode;
    final loc = AppLocalizations.of(context)!;

    if (isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark),
          onPressed: () =>
              ref.read(documentNotifierProvider.notifier).clearSelection(),
        ),
        title: Text('${docState.selectedDocumentIds.length} ${loc.selected}'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.star),
            onPressed: docState.selectedDocumentIds.isEmpty
                ? null
                : () {
                    final firstId = docState.selectedDocumentIds.first;
                    final firstDoc = docState.allDocuments.firstWhere((d) => d.id == firstId);
                    final isAdding = !firstDoc.isFavorite;
                    
                    ref.read(documentNotifierProvider.notifier).toggleFavoriteSelectedDocuments().then((_) {
                      if (context.mounted) {
                        UXFeedback.showStar(context, isAdding ? 'Favorilere Eklendi' : 'Favorilerden Çıkarıldı');
                      }
                    });
                  },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.folder_badge_plus),
            onPressed: docState.selectedDocumentIds.isEmpty
                ? null
                : () {
                    _showMoveToFolderDialog(context, ref);
                  },
          ),
          IconButton(
            icon: Icon(docState.activeSmartFolder == SmartFolderType.archive 
                ? CupertinoIcons.tray_arrow_up 
                : CupertinoIcons.archivebox),
            onPressed: docState.selectedDocumentIds.isEmpty
                ? null
                : () {
                    _toggleArchiveSelectedDocuments(context, ref, docState);
                  },
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.trash, color: Colors.redAccent),
            onPressed: docState.selectedDocumentIds.isEmpty
                ? null
                : () {
                    ref
                        .read(documentNotifierProvider.notifier)
                        .deleteSelectedDocuments();
                  },
          ),
        ],
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Text(loc.homeTab),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? CupertinoIcons.sun_max : CupertinoIcons.moon,
          ),
          onPressed: () {
            ref.read(settingsNotifierProvider.notifier).toggleTheme();
          },
        ),
        IconButton(
          icon: Icon(
            ref.watch(settingsNotifierProvider).isGridView
                ? CupertinoIcons.list_bullet
                : CupertinoIcons.square_grid_2x2,
          ),
          onPressed: () {
            ref.read(settingsNotifierProvider.notifier).toggleViewMode();
          },
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.settings),
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: CupertinoSearchTextField(
            placeholder: loc.searchDocs,
            onChanged: (value) {
              ref.read(documentNotifierProvider.notifier).setSearchQuery(value);
            },
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(116);

  void _showMoveToFolderDialog(BuildContext context, WidgetRef ref) {
    final folders = ref.read(folderNotifierProvider).folders;
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  loc.moveToFolder,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.tray),
                title: Text(loc.mainDir),
                onTap: () {
                  ref
                      .read(documentNotifierProvider.notifier)
                      .moveSelectedDocuments(null).then((_) {
                        if (context.mounted) {
                          UXFeedback.showSuccess(context, 'Klasöre Taşındı');
                        }
                      });
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              if (folders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(loc.noOtherFolder),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      return ListTile(
                        leading: Icon(CupertinoIcons.folder_fill,
                            color: Color(folder.color)),
                        title: Text(folder.name),
                        onTap: () {
                          ref
                              .read(documentNotifierProvider.notifier)
                              .moveSelectedDocuments(folder.id).then((_) {
                                if (context.mounted) {
                                  UXFeedback.showSuccess(context, 'Klasöre Taşındı');
                                }
                              });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _toggleArchiveSelectedDocuments(BuildContext context, WidgetRef ref, DocumentState docState) {
    final firstId = docState.selectedDocumentIds.first;
    final firstDoc = docState.allDocuments.firstWhere((d) => d.id == firstId);
    final isArchiving = !firstDoc.tags.contains('ARCHIVED');

    ref.read(documentNotifierProvider.notifier).toggleArchiveSelectedDocuments().then((_) {
      if (context.mounted) {
        if (isArchiving) {
          UXFeedback.showSuccess(context, 'Arşivlendi', icon: CupertinoIcons.archivebox_fill);
        } else {
          UXFeedback.showSuccess(context, 'Arşivden Çıkarıldı', icon: CupertinoIcons.tray_arrow_up_fill);
        }
      }
    });
  }
}
