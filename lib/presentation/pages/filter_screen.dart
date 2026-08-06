import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/utils/image_processing_service.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/document_page.dart';
import '../../domain/entities/filter_type.dart';
import '../providers/core_providers.dart';
import '../providers/document_provider.dart';
import '../providers/folder_provider.dart';

class FilterScreen extends ConsumerStatefulWidget {
  final String imagePath;
  final int? targetDocumentId;

  const FilterScreen({
    Key? key,
    required this.imagePath,
    this.targetDocumentId,
  }) : super(key: key);

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  FilterType _selectedFilter = FilterType.original;
  bool _isProcessing = false;
  String? _processedImagePath;
  
  @override
  void initState() {
    super.initState();
    _processedImagePath = widget.imagePath;
  }

  Future<void> _applyFilter(FilterType filter) async {
    if (_selectedFilter == filter) return;

    setState(() {
      _selectedFilter = filter;
      _isProcessing = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outPath = '${tempDir.path}/processed_$timestamp.jpg';

      final outFile = await ImageProcessingService.applyFilter(
        File(widget.imagePath),
        filter,
        outPath,
      );

      if (mounted) {
        setState(() {
          _processedImagePath = outFile.path;
          _isProcessing = false;
        });
      }
    } catch (e) {
      debugPrint("Filter error: $e");
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _saveAndContinue() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final repo = ref.read(scannerRepositoryProvider);
      int docId;
      
      // If new document, create it first
      if (widget.targetDocumentId == null) {
        final activeFolderId = ref.read(folderNotifierProvider).activeFolderId;
        final now = DateTime.now();
        final doc = Document(
          title: 'Tarama ${now.day}/${now.month}/${now.year}',
          folderId: activeFolderId,
          createdAt: now,
          updatedAt: now,
          pageCount: 0,
        );
        final createdDoc = await repo.createDocument(doc);
        docId = createdDoc.id!;
      } else {
        docId = widget.targetDocumentId!;
      }

      // Get current pages to find next index
      final pages = await repo.getPagesForDocument(docId);
      final nextIndex = pages.length;

      // Save processed image permanently (move from temp to app dir)
      final appDir = await getApplicationDocumentsDirectory();
      final permanentOriginal = await File(widget.imagePath).copy(
        '${appDir.path}/orig_${docId}_$nextIndex.jpg'
      );
      
      String? permanentProcessed;
      if (_processedImagePath != null && _processedImagePath != widget.imagePath) {
        permanentProcessed = await File(_processedImagePath!).copy(
          '${appDir.path}/proc_${docId}_$nextIndex.jpg'
        ).then((file) => file.path);
      }

      final page = DocumentPage(
        documentId: docId,
        originalImagePath: permanentOriginal.path,
        processedImagePath: permanentProcessed,
        pageIndex: nextIndex,
        appliedFilter: _selectedFilter,
        createdAt: DateTime.now(),
      );

      await repo.addPageToDocument(page);
      
      // Refresh documents
      await ref.read(documentNotifierProvider.notifier).loadDocuments();

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        Navigator.of(context).pop(); // Go back to Dashboard (or Page Viewer)
      }
    } catch (e) {
      debugPrint("Save error: $e");
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Filtrele', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _saveAndContinue,
            child: const Text('Kaydet', style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_processedImagePath != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.file(
                      File(_processedImagePath!),
                      fit: BoxFit.contain,
                    ),
                  ),
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CupertinoActivityIndicator(radius: 20, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: 120,
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: FilterType.values.map((filter) {
                return _buildFilterThumb(filter);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterThumb(FilterType filter) {
    final isSelected = _selectedFilter == filter;
    
    return GestureDetector(
      onTap: () => _applyFilter(filter),
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? CupertinoColors.activeBlue : Colors.transparent,
                  width: 3,
                ),
                color: Colors.grey.shade800,
              ),
              child: Center(
                child: Icon(
                  _getFilterIcon(filter),
                  color: isSelected ? CupertinoColors.activeBlue : Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filter.name,
              style: TextStyle(
                color: isSelected ? CupertinoColors.activeBlue : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFilterIcon(FilterType type) {
    switch (type) {
      case FilterType.original:
        return CupertinoIcons.photo;
      case FilterType.blackAndWhite:
        return CupertinoIcons.doc_text;
      case FilterType.grayscale:
        return CupertinoIcons.drop;
      case FilterType.magicColor:
        return CupertinoIcons.wand_rays;
    }
  }
}
