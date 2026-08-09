import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/entities/batch_item.dart';
import '../providers/batch_conversion_provider.dart';
import 'batch_save_result_screen.dart';

class BatchConversionScreen extends ConsumerStatefulWidget {
  const BatchConversionScreen({super.key});

  @override
  ConsumerState<BatchConversionScreen> createState() => _BatchConversionScreenState();
}

class _BatchConversionScreenState extends ConsumerState<BatchConversionScreen> {
  
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      final List<BatchItem> newItems = [];
      for (var file in result.files) {
        if (file.path == null) continue;
        
        // Simple heuristic to determine default target based on extension
        final ext = file.extension?.toLowerCase() ?? '';
        String conversionType = 'media';
        String targetFormat = 'mp3';
        
        if (['mp3', 'wav', 'm4a', 'flac'].contains(ext)) {
          // Default to transcription for audio files (can be changed by user later)
          conversionType = 'transcription';
          targetFormat = 'txt';
        } else if (['jpg', 'jpeg', 'png'].contains(ext)) {
          conversionType = 'image_to_pdf';
          targetFormat = 'pdf';
        } else if (ext == 'pdf') {
          conversionType = 'pdf_to_image';
          targetFormat = 'jpg';
        } else if (['mp4', 'mov', 'avi'].contains(ext)) {
          conversionType = 'media';
          targetFormat = 'mp4';
        }
        
        newItems.add(BatchItem(
          sourcePath: file.path!,
          sourceFileName: file.name,
          targetFormat: targetFormat,
          conversionType: conversionType,
        ));
      }
      
      ref.read(batchConversionProvider.notifier).addJobs(newItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchConversionProvider);
    final items = state.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toplu Dönüştürme Motoru'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.trash),
            tooltip: 'Tamamlananları Temizle',
            onPressed: () {
              ref.read(batchConversionProvider.notifier).clearCompleted();
            },
          )
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.layers_alt, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('İşlem kuyruğu boş.', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(CupertinoIcons.add),
                    label: const Text('Dosyaları Seç'),
                  )
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              onReorder: (oldIndex, newIndex) {
                ref.read(batchConversionProvider.notifier).reorderItems(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildBatchItemCard(item, key: ValueKey(item.id));
              },
            ),
      floatingActionButton: items.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (items.any((e) => e.status == BatchItemStatus.paused || e.status == BatchItemStatus.failed))
                  FloatingActionButton.extended(
                    heroTag: 'startAll',
                    onPressed: () {
                      ref.read(batchConversionProvider.notifier).startAll();
                    },
                    icon: const Icon(CupertinoIcons.play_fill),
                    label: const Text('Tümünü Başlat'),
                    backgroundColor: Colors.green,
                  ),
                if (items.every((e) => e.status == BatchItemStatus.completed))
                  FloatingActionButton.extended(
                    heroTag: 'saveAll',
                    onPressed: () {
                      // Navigate to BatchSaveResultScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BatchSaveResultScreen(),
                        ),
                      );
                    },
                    icon: const Icon(CupertinoIcons.lock_shield),
                    label: const Text('Tümünü Kaydet'),
                    backgroundColor: Colors.blueAccent,
                  ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  heroTag: 'addMore',
                  onPressed: _pickFiles,
                  icon: const Icon(CupertinoIcons.add),
                  label: const Text('Ekle'),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildBatchItemCard(BatchItem item, {Key? key}) {
    IconData statusIcon;
    Color statusColor;

    switch (item.status) {
      case BatchItemStatus.pending:
        statusIcon = CupertinoIcons.time;
        statusColor = Colors.orange;
        break;
      case BatchItemStatus.converting:
        statusIcon = CupertinoIcons.arrow_2_circlepath;
        statusColor = Colors.blue;
        break;
      case BatchItemStatus.completed:
        statusIcon = CupertinoIcons.checkmark_circle_fill;
        statusColor = Colors.green;
        break;
      case BatchItemStatus.failed:
        statusIcon = CupertinoIcons.exclamationmark_circle_fill;
        statusColor = Colors.red;
        break;
      case BatchItemStatus.paused:
        statusIcon = CupertinoIcons.pause_circle_fill;
        statusColor = Colors.grey;
        break;
    }

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.sourceFileName,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (item.status != BatchItemStatus.pending && item.status != BatchItemStatus.paused) return;
                    String newType = 'media';
                    if (val == 'txt') newType = 'transcription';
                    else if (val == 'pdf') newType = 'image_to_pdf';
                    else if (val == 'jpg' && item.sourceFileName.toLowerCase().endsWith('pdf')) newType = 'pdf_to_image';
                    ref.read(batchConversionProvider.notifier).updateItemFormat(item.id!, val, newType);
                  },
                  itemBuilder: (context) {
                    final ext = item.sourceFileName.split('.').last.toLowerCase();
                    List<String> options = ['mp4', 'mp3', 'wav', 'm4a', 'gif'];
                    if (['mp3', 'wav', 'm4a', 'flac'].contains(ext)) options = ['txt', 'mp4', 'mp3', 'wav'];
                    else if (['jpg', 'jpeg', 'png'].contains(ext)) options = ['pdf', 'gif'];
                    else if (ext == 'pdf') options = ['jpg'];
                    
                    return options.map((e) => PopupMenuItem(value: e, child: Text(e.toUpperCase()))).toList();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${item.conversionType} ➔ ${item.targetFormat.toUpperCase()}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(CupertinoIcons.chevron_down, size: 14, color: Theme.of(context).primaryColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getStatusText(item.status),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w500),
                  ),
                ),
                if (item.status == BatchItemStatus.converting || item.status == BatchItemStatus.pending)
                  IconButton(
                    icon: const Icon(CupertinoIcons.pause, size: 20),
                    onPressed: () => ref.read(batchConversionProvider.notifier).pauseJob(item.id!),
                  ),
                if (item.status == BatchItemStatus.paused || item.status == BatchItemStatus.failed)
                  IconButton(
                    icon: const Icon(CupertinoIcons.play, size: 20),
                    onPressed: () => ref.read(batchConversionProvider.notifier).resumeJob(item.id!),
                  ),
                IconButton(
                  icon: const Icon(CupertinoIcons.clear_circled, size: 20, color: Colors.redAccent),
                  onPressed: () => ref.read(batchConversionProvider.notifier).cancelJob(item.id!),
                ),
              ],
            ),
            if (item.status == BatchItemStatus.converting) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: item.progress),
            ],
            if (item.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                item.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            if (item.status == BatchItemStatus.completed && item.outputPath != null) ...[
              const SizedBox(height: 8),
              Text(
                'Kaydedildi: ${item.outputPath!.split('/').last}',
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
            ]
          ],
        ),
      ),
    );
  }

  String _getStatusText(BatchItemStatus status) {
    switch (status) {
      case BatchItemStatus.pending: return 'Bekliyor...';
      case BatchItemStatus.converting: return 'İşleniyor...';
      case BatchItemStatus.completed: return 'Tamamlandı';
      case BatchItemStatus.failed: return 'Hata Oluştu';
      case BatchItemStatus.paused: return 'Duraklatıldı';
    }
  }
}
