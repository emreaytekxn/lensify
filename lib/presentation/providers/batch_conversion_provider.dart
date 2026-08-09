import 'dart:async';
import 'dart:io' as dart_io;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../../domain/entities/batch_item.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../../core/utils/media_conversion_service.dart';
import '../../core/utils/transcription_service.dart';
import 'core_providers.dart'; // To access scannerRepositoryProvider

class BatchConversionState {
  final List<BatchItem> items;
  final bool isProcessing;

  BatchConversionState({
    required this.items,
    this.isProcessing = false,
  });

  BatchConversionState copyWith({
    List<BatchItem>? items,
    bool? isProcessing,
  }) {
    return BatchConversionState(
      items: items ?? this.items,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class BatchConversionNotifier extends StateNotifier<BatchConversionState> {
  final ScannerRepository _repository;
  
  // Semaphore/Concurrency control
  final int _maxConcurrent = 2;
  int _activeJobs = 0;
  
  // Track active conversion futures/cancellations (pseudo-cancellation for now)
  final Set<int> _cancelledIds = {};

  BatchConversionNotifier(this._repository) : super(BatchConversionState(items: [])) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _repository.getAllBatchItems();
    state = state.copyWith(items: items);
    
    // Auto-resume pending or converting items
    for (final item in items) {
      if (item.status == BatchItemStatus.converting) {
        // Reset converting to pending since app was closed
        await _updateItem(item.copyWith(status: BatchItemStatus.pending, progress: 0.0));
      }
    }
    
    _processQueue();
  }
  
  Future<void> _updateItem(BatchItem item) async {
    await _repository.updateBatchItem(item);
    final updatedList = state.items.map((e) => e.id == item.id ? item : e).toList();
    state = state.copyWith(items: updatedList);
  }

  Future<void> updateItemFormat(int id, String newFormat, String newType) async {
    final item = state.items.firstWhere((e) => e.id == id);
    if (item.status == BatchItemStatus.pending || item.status == BatchItemStatus.paused) {
      await _updateItem(item.copyWith(targetFormat: newFormat, conversionType: newType));
    }
  }

  Future<void> reorderItems(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final items = List<BatchItem>.from(state.items);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = state.copyWith(items: items);
    // Ideally we would update order in DB here, but for now in-memory is fine for the session
  }

  Future<void> addJobs(List<BatchItem> newItems) async {
    for (var item in newItems) {
      final savedItem = await _repository.createBatchItem(item);
      state = state.copyWith(items: [savedItem, ...state.items]);
    }
    _processQueue();
  }

  Future<void> pauseJob(int id) async {
    final item = state.items.firstWhere((e) => e.id == id);
    if (item.status == BatchItemStatus.pending || item.status == BatchItemStatus.converting) {
      _cancelledIds.add(id); // Attempt to cancel if running
      await _updateItem(item.copyWith(status: BatchItemStatus.paused));
    }
  }

  Future<void> resumeJob(int id) async {
    final item = state.items.firstWhere((e) => e.id == id);
    if (item.status == BatchItemStatus.paused || item.status == BatchItemStatus.failed) {
      _cancelledIds.remove(id);
      await _updateItem(item.copyWith(status: BatchItemStatus.pending, errorMessage: null));
      _processQueue();
    }
  }
  
  Future<void> cancelJob(int id) async {
    _cancelledIds.add(id);
    await _repository.deleteBatchItem(id);
    state = state.copyWith(items: state.items.where((e) => e.id != id).toList());
  }
  
  Future<void> clearCompleted() async {
    await _repository.clearCompletedBatchItems();
    state = state.copyWith(items: state.items.where((e) => e.status != BatchItemStatus.completed).toList());
  }

  void _processQueue() async {
    if (state.isProcessing) return;
    
    state = state.copyWith(isProcessing: true);
    
    while (true) {
      // Find pending items
      final pendingItems = state.items.where((e) => e.status == BatchItemStatus.pending).toList();
      
      if (pendingItems.isEmpty) break;
      
      if (_activeJobs >= _maxConcurrent) {
        // Wait until a slot opens
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }
      
      final nextJob = pendingItems.first;
      
      // If transcription is running, limit concurrency to 1 to avoid memory crash
      bool isWhisperRunning = state.items.any((e) => e.status == BatchItemStatus.converting && e.conversionType == 'transcription');
      if (isWhisperRunning && nextJob.conversionType == 'transcription') {
         await Future.delayed(const Duration(milliseconds: 1000));
         continue; // Wait for the other whisper to finish
      }

      _activeJobs++;
      _runJob(nextJob).then((_) {
        _activeJobs--;
      });
    }
    
    state = state.copyWith(isProcessing: false);
  }

  Future<void> _runJob(BatchItem job) async {
    // Mark as converting
    var currentJob = job.copyWith(status: BatchItemStatus.converting, progress: 0.1);
    await _updateItem(currentJob);

    try {
      if (_cancelledIds.contains(job.id)) throw Exception('Cancelled');

      String? resultPath;
      
      if (job.conversionType == 'media') {
         resultPath = await MediaConversionService.convertMedia(job.sourcePath, job.targetFormat);
      } else if (job.conversionType == 'transcription') {
         // Step 1: convert to wav
         final wavPath = await MediaConversionService.convertMedia(job.sourcePath, 'wav');
         if (wavPath == null) throw Exception('Media conversion failed');
         if (_cancelledIds.contains(job.id)) throw Exception('Cancelled');
         
         currentJob = currentJob.copyWith(progress: 0.5);
         await _updateItem(currentJob);
         
         final text = await TranscriptionService.transcribeAudio(wavPath);
         if (text == null || text.isEmpty) throw Exception('Transcription failed');
         
         // For text, we can just save it as a .txt file
         // But wait, where do we save it? outputPath should be generated.
         // Since this is offline and background, let's just return the text as the "outputPath" for now,
         // or we can write to a temp file and return that path.
         final tempDir = await _getTempDir();
         final txtPath = '$tempDir/transcript_${DateTime.now().millisecondsSinceEpoch}.txt';
         await _writeStringToFile(txtPath, text);
         resultPath = txtPath;
      } else {
         throw Exception('Unsupported conversion type: ${job.conversionType}');
      }
      
      if (_cancelledIds.contains(job.id)) throw Exception('Cancelled');
      
      if (resultPath != null) {
        await _updateItem(currentJob.copyWith(
          status: BatchItemStatus.completed, 
          progress: 1.0, 
          outputPath: resultPath,
          completedAt: DateTime.now()
        ));
      } else {
        throw Exception('Conversion returned null');
      }
    } catch (e) {
      if (e.toString() == 'Exception: Cancelled') {
         // Don't update, it was paused or deleted
      } else {
         await _updateItem(currentJob.copyWith(
           status: BatchItemStatus.failed, 
           errorMessage: e.toString()
         ));
      }
    }
  }

  // Helpers
  Future<String> _getTempDir() async {
    // Using simple path provider fallback here for simplicity, in real implementation inject it.
    // For now we will rely on dart:io if possible, but actually let's use the standard flutter path_provider 
    // Wait, path_provider is already in pubspec.
    // Let's import it here.
    return (await path_provider.getTemporaryDirectory()).path;
  }
  
  Future<void> _writeStringToFile(String path, String content) async {
    final file = dart_io.File(path);
    await file.writeAsString(content);
  }
}

// Global Provider
final batchConversionProvider = StateNotifierProvider<BatchConversionNotifier, BatchConversionState>((ref) {
  final repo = ref.watch(scannerRepositoryProvider);
  return BatchConversionNotifier(repo);
});
