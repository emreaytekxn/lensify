import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '../../../domain/entities/document.dart';
import '../../providers/document_provider.dart';
import '../../providers/folder_provider.dart';
import '../../providers/core_providers.dart';
import '../../widgets/loading_overlay.dart';

class PdfEncryptionScreen extends ConsumerStatefulWidget {
  const PdfEncryptionScreen({super.key});

  @override
  ConsumerState<PdfEncryptionScreen> createState() => _PdfEncryptionScreenState();
}

class _PdfEncryptionScreenState extends ConsumerState<PdfEncryptionScreen> {
  File? _selectedPdf;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPdf = File(result.files.single.path!);
        _titleController.text = 'Şifreli - ${result.files.single.name}';
      });
    }
  }

  Future<void> _encryptPdf() async {
    if (_selectedPdf == null || _passwordController.text.isEmpty) return;
    
    LoadingOverlay.show(context, message: 'Şifreleniyor...');
    
    try {
      final bytes = await _selectedPdf!.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      
      final security = document.security;
      security.userPassword = _passwordController.text;
      security.ownerPassword = _passwordController.text;
      security.algorithm = PdfEncryptionAlgorithm.aesx256Bit;
      
      final encryptedBytes = await document.save();
      document.dispose();
      
      final appDir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${appDir.path}/pdfs');
      if (!await pdfDir.exists()) await pdfDir.create(recursive: true);
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${pdfDir.path}/encrypted_$timestamp.pdf');
      await file.writeAsBytes(encryptedBytes);
      
      final activeFolderId = ref.read(folderNotifierProvider).activeFolderId;
      final repo = ref.read(scannerRepositoryProvider);
      
      final doc = Document(
        title: _titleController.text,
        folderId: activeFolderId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        pageCount: 0,
        pdfPath: file.path,
        isFavorite: false,
        fileSize: encryptedBytes.length,
        fileType: 'pdf',
      );
      
      await repo.createDocument(doc);
      await ref.read(documentNotifierProvider.notifier).loadDocuments();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF başarıyla şifrelendi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) LoadingOverlay.hide(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Şifreleme')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(CupertinoIcons.lock_shield, size: 64, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 16),
                  const Text(
                    'Askeri Düzey AES-256 Şifreleme',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Seçtiğiniz PDF dosyası güvenli bir şekilde şifrelenerek yeni bir kopya oluşturulur.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (_selectedPdf == null)
              ElevatedButton.icon(
                onPressed: _pickPdf,
                icon: const Icon(CupertinoIcons.doc_text),
                label: const Text('PDF Dosyası Seç'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              )
            else ...[
              Card(
                child: ListTile(
                  leading: const Icon(CupertinoIcons.doc_fill, color: Colors.redAccent),
                  title: Text(_selectedPdf!.path.split('/').last),
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.clear_circled),
                    onPressed: () => setState(() => _selectedPdf = null),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Yeni Dosya Adı',
                  prefixIcon: Icon(CupertinoIcons.pencil),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Şifre Belirleyin',
                  prefixIcon: Icon(CupertinoIcons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _encryptPdf,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Şifrele ve Kaydet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
