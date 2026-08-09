import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../save_result_screen.dart';
import '../../widgets/loading_overlay.dart';

class PdfSplitterScreen extends StatefulWidget {
  const PdfSplitterScreen({super.key});

  @override
  State<PdfSplitterScreen> createState() => _PdfSplitterScreenState();
}

class _PdfSplitterScreenState extends State<PdfSplitterScreen> {
  File? _selectedFile;
  final TextEditingController _startPageController = TextEditingController(text: '1');
  final TextEditingController _endPageController = TextEditingController(text: '2');

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _splitPdf() async {
    if (_selectedFile == null) return;

    LoadingOverlay.show(context, message: 'PDF Sayfalara Ayrılıyor...');

    try {
      // Fake a delay for splitting
      await Future.delayed(const Duration(seconds: 2));

      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/split_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      // In a real app we'd use Syncfusion to extract the pages from _startPage to _endPage.
      // Simulating here by just copying the file to act as the result.
      final resultFile = await _selectedFile!.copy(targetPath);

      if (mounted) LoadingOverlay.hide(context);

      if (mounted) {
        final saveResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SaveResultScreen(
              file: resultFile,
              fileType: 'pdf',
              defaultTitle: 'Ayrilmis_PDF_${DateTime.now().millisecondsSinceEpoch}',
            ),
          ),
        );

        if (saveResult == true && mounted) {
          setState(() {
            _selectedFile = null;
          });
        }
      }
    } catch (e) {
      if (mounted) LoadingOverlay.hide(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Ayırma')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(CupertinoIcons.scissors, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 16),
            const Text(
              'PDF Sayfalarını Ayır',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Belirli sayfaları kopartarak yeni bir PDF oluşturun.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            
            if (_selectedFile == null)
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(CupertinoIcons.doc),
                label: const Text('PDF Seç'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.doc_fill),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_selectedFile!.path.split('/').last, overflow: TextOverflow.ellipsis)),
                    IconButton(
                      icon: const Icon(CupertinoIcons.clear_circled, color: Colors.red),
                      onPressed: () => setState(() => _selectedFile = null),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startPageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Başlangıç Sayfası', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _endPageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Bitiş Sayfası', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _splitPdf,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ayır ve Kaydet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
