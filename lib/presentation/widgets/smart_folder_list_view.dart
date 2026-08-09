import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/document_provider.dart';
import '../providers/document_state.dart';
import '../providers/settings_provider.dart';

class SmartFolderListView extends ConsumerWidget {
  const SmartFolderListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docState = ref.watch(documentNotifierProvider);
    final activeSmartFolder = docState.activeSmartFolder;

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    
    final folders = [
      {'type': SmartFolderType.none, 'icon': Icons.all_inclusive, 'label': isEn ? 'All' : 'Tümü', 'color': Colors.blueGrey},
      {'type': SmartFolderType.recent, 'icon': Icons.access_time, 'label': isEn ? 'Last 7 Days' : 'Son 7 Gün', 'color': Colors.blue},
      {'type': SmartFolderType.favorites, 'icon': Icons.star, 'label': isEn ? 'Favorites' : 'Favoriler', 'color': Colors.orange},
      {'type': SmartFolderType.largeFiles, 'icon': Icons.folder_special, 'label': isEn ? 'Large Files' : 'Büyük Dosyalar', 'color': Colors.redAccent},
      {'type': SmartFolderType.pdf, 'icon': Icons.picture_as_pdf, 'label': isEn ? 'PDFs' : 'PDF\'ler', 'color': Colors.red},
      {'type': SmartFolderType.image, 'icon': Icons.image, 'label': isEn ? 'Images' : 'Görseller', 'color': Colors.green},
      {'type': SmartFolderType.audio, 'icon': Icons.audiotrack, 'label': isEn ? 'Audios' : 'Sesler', 'color': Colors.purple},
      {'type': SmartFolderType.text, 'icon': Icons.description, 'label': isEn ? 'Texts' : 'Metinler', 'color': Colors.teal},
    ];

    final showArchives = ref.watch(settingsNotifierProvider).showArchivesInHome;
    if (showArchives) {
      folders.add({'type': SmartFolderType.archive, 'icon': Icons.archive, 'label': isEn ? 'Archives' : 'Arşivlerim', 'color': Colors.indigo});
    }

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: folders.length,
        itemBuilder: (context, index) {
          final folder = folders[index];
          final type = folder['type'] as SmartFolderType;
          final isSelected = activeSmartFolder == type;
          final color = folder['color'] as Color;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Icon(
                folder['icon'] as IconData,
                color: isSelected ? Colors.white : color,
                size: 18,
              ),
              label: Text(
                folder['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: color,
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : color.withValues(alpha: 0.3),
                ),
              ),
              onSelected: (selected) {
                ref.read(documentNotifierProvider.notifier).setSmartFolder(type);
              },
            ),
          );
        },
      ),
    );
  }
}
