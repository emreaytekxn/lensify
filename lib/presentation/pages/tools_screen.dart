import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'barcode_scanner_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/document_import_service.dart';
import '../providers/core_providers.dart';
import '../providers/document_provider.dart';
import '../providers/folder_provider.dart';
import '../widgets/loading_overlay.dart';
import '../../core/utils/format_conversion_service.dart';
import 'media_converter_screen.dart';
import 'transcription_screen.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

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
            style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 14),
          ),
          const SizedBox(height: 24),
          _buildToolCard(
            context,
            icon: CupertinoIcons.doc_on_doc,
            color: Colors.blue,
            title: 'Fotoğraftan PDF\'e',
            description:
                'Birden fazla görseli tek bir PDF dökümanında birleştirin. (JPEG/PNG ➔ PDF)',
            onTap: () async {
              LoadingOverlay.show(context, message: 'İçe aktarılıyor...');
              try {
                final folderId =
                    ref.read(folderNotifierProvider).activeFolderId;
                final repo = ref.read(scannerRepositoryProvider);
                await DocumentImportService(repo).importFromGallery(folderId);
                ref.read(documentNotifierProvider.notifier).loadDocuments();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Fotoğraflar başarıyla aktarıldı!')),
                  );
                }
              } finally {
                if (context.mounted) LoadingOverlay.hide(context);
              }
            },
          ),
          _buildToolCard(
            context,
            icon: CupertinoIcons.photo_on_rectangle,
            color: Colors.orange,
            title: 'PDF\'den Fotoğrafa',
            description:
                'PDF belgelerinizin sayfalarını yüksek çözünürlüklü görsellere dönüştürün. (PDF ➔ JPEG)',
            onTap: () async {
              LoadingOverlay.show(context, message: 'PDF dönüştürülüyor...');
              try {
                final folderId =
                    ref.read(folderNotifierProvider).activeFolderId;
                final repo = ref.read(scannerRepositoryProvider);
                await DocumentImportService(repo).importPdf(folderId);
                ref.read(documentNotifierProvider.notifier).loadDocuments();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'PDF sayfaları başarıyla resme dönüştürüldü!')),
                  );
                }
              } finally {
                if (context.mounted) LoadingOverlay.hide(context);
              }
            },
          ),
          _buildToolCard(
            context,
            icon: CupertinoIcons.waveform_path_badge_plus,
            color: Colors.blueAccent,
            title: 'Yapay Zeka Sesi Yazıya Çevir',
            description:
                'Videoları ve ses kayıtlarını internetsiz metne dönüştürün.',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TranscriptionScreen()));
            },
          ),
          _buildToolCard(
            context,
            icon: CupertinoIcons.infinite,
            color: Colors.deepPurple,
            title: 'Evrensel Medya Dönüştürücü',
            description:
                'Ses ve videoları çevrimdışı dönüştürün (MP4, MP3 vb.)',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MediaConverterScreen()));
            },
          ),
          _buildToolCard(
            context,
            icon: CupertinoIcons.qrcode_viewfinder,
            color: Colors.purple,
            title: 'QR / Barkod Oku',
            description: 'Kamerayla hızlıca kod tarayın',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BarcodeScannerScreen()));
            },
          ),
          _buildToolCard(
            context,
            icon: CupertinoIcons.text_aligncenter,
            color: Colors.green,
            title: 'Resimden Metne (TXT)',
            description:
                'Fotoğraftaki yazıları otomatik olarak .txt formatına dönüştürün.',
            onTap: () async {
              LoadingOverlay.show(context, message: 'Metin analiz ediliyor...');
              try {
                final success =
                    await FormatConversionService.extractTextToTxt();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Metin dosyası oluşturuldu!')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Hata: $e')));
                }
              } finally {
                if (context.mounted) LoadingOverlay.hide(context);
              }
            },
          ),
          _buildToolCard(
            context,
            icon: CupertinoIcons.lock,
            color: Colors.redAccent,
            title: 'PDF Şifreleme',
            description:
                'PDF belgelerinize güvenli AES 256-Bit parola ekleyin.',
            onTap: () async {
              _showPasswordDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('PDF Şifreleme'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration:
                const InputDecoration(hintText: 'Yeni parolanızı girin'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final pwd = passwordController.text.trim();
                if (pwd.isEmpty) return;
                Navigator.pop(context); // close dialog

                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );

                if (result == null || result.files.single.path == null) return;

                if (context.mounted) {
                  LoadingOverlay.show(context, message: 'PDF şifreleniyor...');
                }

                String? encryptedPath;
                try {
                  encryptedPath = await FormatConversionService.encryptPdf(
                      result.files.single.path!, pwd);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Hata: $e')));
                  }
                } finally {
                  if (context.mounted) LoadingOverlay.hide(context);
                }

                if (encryptedPath != null) {
                  await Share.shareXFiles(
                    [XFile(encryptedPath)],
                    text: 'Kawaru ile şifrelenmiş PDF',
                    sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
                  );
                }
              },
              child: const Text('Şifrele'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
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
        side: BorderSide(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
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
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(CupertinoIcons.chevron_right,
                  size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
