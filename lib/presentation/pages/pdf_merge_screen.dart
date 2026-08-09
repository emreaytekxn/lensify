import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../core/utils/pdf_tools_service.dart';
import '../widgets/loading_overlay.dart';
import 'save_result_screen.dart';

class PdfMergeScreen extends StatefulWidget {
  const PdfMergeScreen({super.key});

  @override
  State<PdfMergeScreen> createState() => _PdfMergeScreenState();
}

class _PdfMergeScreenState extends State<PdfMergeScreen> {
  final List<PlatformFile> _selectedFiles = [];
  bool _isProcessing = false;

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final PlatformFile item = _selectedFiles.removeAt(oldIndex);
      _selectedFiles.insert(newIndex, item);
    });
  }

  Future<void> _mergePdfs() async {
    if (_selectedFiles.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Birleştirmek için en az 2 PDF seçmelisiniz.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });
    
    LoadingOverlay.show(context, message: 'PDF\'ler birleştiriliyor...');

    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      final paths = _selectedFiles.map((f) => f.path!).toList();

      await PdfToolsService.mergePdfs(paths, outputPath);

      if (mounted) {
        LoadingOverlay.hide(context);
        
        final saveResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SaveResultScreen(
              file: File(outputPath),
              fileType: 'pdf',
              defaultTitle: 'Birlestirilmis_PDF_${DateTime.now().millisecondsSinceEpoch}',
            ),
          ),
        );
        
        if (saveResult == true && mounted) {
          setState(() {
            _selectedFiles.clear();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}')),
        );
      }
    } finally {
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
      appBar: AppBar(
        title: const Text('PDF Birleştir'),
      ),
      body: Stack(
        children: [
          _selectedFiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.doc_on_doc, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('PDF dosyalarınızı seçin', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(CupertinoIcons.add),
                        label: const Text('Dosya Ekle'),
                      )
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _selectedFiles.length,
                        onReorder: _onReorder,
                        itemBuilder: (context, index) {
                          final file = _selectedFiles[index];
                          return Card(
                            key: ValueKey(file.path ?? file.name + index.toString()),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(CupertinoIcons.doc_text, color: Colors.redAccent),
                              title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('${(file.size / 1024 / 1024).toStringAsFixed(2)} MB'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(CupertinoIcons.clear_circled, color: Colors.red),
                                    onPressed: () => _removeFile(index),
                                  ),
                                  const Icon(Icons.drag_handle, color: Colors.grey),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickFiles,
                              icon: const Icon(CupertinoIcons.add),
                              label: const Text('Daha Fazla'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _selectedFiles.length >= 2 ? _mergePdfs : null,
                              icon: const Icon(CupertinoIcons.check_mark_circled),
                              label: const Text('Birleştir'),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
        ],
      ),
    );
  }
}
