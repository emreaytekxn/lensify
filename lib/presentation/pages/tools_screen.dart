import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/document_import_service.dart';
import '../providers/core_providers.dart';
import '../providers/document_provider.dart';
import '../providers/folder_provider.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Araçlar & Dönüştürücü'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Evrensel Medya Araçları',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Profesyonel format dönüştürme ve işleme araçları ile dosyalarınızı çevrimdışı ve güvenli bir şekilde yönetin.',
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          _buildToolCard(
            context,
            icon: CupertinoIcons.doc_on_doc,
            color: Colors.blue,
            title: 'Fotoğraftan PDF\'e',
            description: 'Birden fazla görseli tek bir PDF dökümanında birleştirin. (JPEG/PNG ➔ PDF)',
            onTap: () async {
              final folderId = ref.read(folderNotifierProvider).activeFolderId;
              final repo = ref.read(scannerRepositoryProvider);
              await DocumentImportService(repo).importFromGallery(folderId);
              ref.read(documentNotifierProvider.notifier).loadDocuments();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fotoğraflar PDF (Belge) olarak aktarıldı!')),
              );
            },
          ),
          
          _buildToolCard(
            context,
            icon: CupertinoIcons.photo_on_rectangle,
            color: Colors.orange,
            title: 'PDF\'den Fotoğrafa',
            description: 'PDF belgelerinizin sayfalarını yüksek çözünürlüklü görsellere dönüştürün. (PDF ➔ JPEG)',
            onTap: () async {
              final folderId = ref.read(folderNotifierProvider).activeFolderId;
              final repo = ref.read(scannerRepositoryProvider);
              await DocumentImportService(repo).importPdf(folderId);
              ref.read(documentNotifierProvider.notifier).loadDocuments();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF sayfaları başarıyla resme dönüştürüldü!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
