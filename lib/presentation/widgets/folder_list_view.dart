import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/folder_provider.dart';
import 'create_folder_dialog.dart';
import '../../core/utils/security_service.dart';

class FolderListView extends ConsumerWidget {
  const FolderListView({Key? key}) : super(key: key);

  void _showCreateFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateFolderDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderState = ref.watch(folderNotifierProvider);
    final activeId = folderState.activeFolderId;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: folderState.folders.length + 2, // +1 for "All Documents", +1 for "New Folder"
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All Documents" item
            final isActive = activeId == null;
            return _buildChip(
              context: context,
              label: 'Tüm Belgeler',
              icon: CupertinoIcons.tray_full,
              isActive: isActive,
              onTap: () => ref.read(folderNotifierProvider.notifier).setActiveFolder(null),
              activeColor: Theme.of(context).primaryColor,
            );
          }

          if (index == folderState.folders.length + 1) {
            // "New Folder" item
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ActionChip(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                ),
                label: Text(
                  'Yeni Klasör',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                avatar: Icon(CupertinoIcons.plus, size: 16, color: Theme.of(context).primaryColor),
                onPressed: () => _showCreateFolderDialog(context),
              ),
            );
          }

          final folder = folderState.folders[index - 1];
          final isActive = activeId == folder.id;
          final folderColor = Color(folder.color);

          return _buildChip(
            context: context,
            label: folder.name,
            icon: folder.isLocked ? CupertinoIcons.lock_fill : CupertinoIcons.folder_fill,
            isActive: isActive,
            onTap: () async {
              if (folder.isLocked && !isActive) {
                final auth = await SecurityService.authenticate(reason: '${folder.name} klasörüne erişmek için doğrulama gerekiyor');
                if (auth) {
                  ref.read(folderNotifierProvider.notifier).setActiveFolder(folder.id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doğrulama başarısız!')));
                }
              } else {
                ref.read(folderNotifierProvider.notifier).setActiveFolder(folder.id);
              }
            },
            onLongPress: () {
              _showFolderOptions(context, ref, folder);
            },
            activeColor: folderColor,
            iconColor: folderColor,
          );
        },
      ),
    );
  }

  void _showFolderOptions(BuildContext context, WidgetRef ref, dynamic folder) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(folder.isLocked ? CupertinoIcons.lock_open : CupertinoIcons.lock),
                title: Text(folder.isLocked ? 'Kilidi Kaldır' : 'Klasörü Kilitle (FaceID)'),
                onTap: () async {
                  Navigator.pop(context);
                  final auth = await SecurityService.authenticate(reason: 'Klasör kilit ayarlarını değiştirmek için doğrulama gerekiyor');
                  if (auth) {
                    ref.read(folderNotifierProvider.notifier).toggleFolderLock(folder.id!);
                  }
                },
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    required Color activeColor,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isActive 
        ? activeColor.withOpacity(isDark ? 0.2 : 0.1)
        : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05));
    final textColor = isActive 
        ? activeColor 
        : Theme.of(context).textTheme.bodyLarge!.color!;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: isActive ? Border.all(color: activeColor.withOpacity(0.5)) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? activeColor : (iconColor ?? textColor.withOpacity(0.7)),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
