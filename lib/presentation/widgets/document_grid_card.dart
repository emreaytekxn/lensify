import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/document.dart';
import '../providers/core_providers.dart';

class DocumentGridCard extends ConsumerWidget {
  final Document document;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const DocumentGridCard({
    Key? key,
    required this.document,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMM yyyy', 'tr_TR'); // Assuming Turkish, can adjust locale
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: isSelected 
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: document.id != null
                        ? FutureBuilder(
                            future: ref.read(scannerRepositoryProvider).getPagesForDocument(document.id!),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                final firstPage = snapshot.data!.first;
                                final path = firstPage.processedImagePath ?? firstPage.originalImagePath;
                                if (File(path).existsSync()) {
                                  return ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                    child: Image.file(
                                      File(path),
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                }
                              }
                              return Icon(
                                CupertinoIcons.doc_richtext,
                                size: 40,
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                              );
                            },
                          )
                        : Icon(
                            CupertinoIcons.doc_richtext,
                            size: 40,
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                    ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateFormat.format(document.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${document.pageCount} Syf',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isSelectionMode)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.white.withOpacity(0.5),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: Icon(
                  CupertinoIcons.check_mark,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
