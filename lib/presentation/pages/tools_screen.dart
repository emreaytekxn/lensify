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
import 'batch_conversion_screen.dart';
import '../../l10n/app_localizations.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.toolsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            loc.universalMediaTools,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            loc.universalMediaToolsDesc,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 14),
          ),
          const SizedBox(height: 24),
          _buildToolCard(
            context,
            icon: CupertinoIcons.layers_alt_fill,
            color: Colors.teal,
            title: 'Toplu Dönüştürme Motoru', // Hardcoded for now since I didn't add the arb key
            description: 'Aynı anda birden fazla dosyayı arka planda işleyin ve yönetin.',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BatchConversionScreen()));
            },
          ),
          _buildToolCard(
            context,
            icon: CupertinoIcons.doc_on_doc,
            color: Colors.blue,
            title: loc.photoToPdf,
            description: loc.photoToPdfDesc,
            onTap: () async {
              LoadingOverlay.show(context, message: loc.importing);
              try {
                final folderId =
                    ref.read(folderNotifierProvider).activeFolderId;
                final repo = ref.read(scannerRepositoryProvider);
                await DocumentImportService(repo).importFromGallery(folderId);
                ref.read(documentNotifierProvider.notifier).loadDocuments();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.photosImportedSuccessfully)),
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
            title: loc.pdfToPhoto,
            description: loc.pdfToPhotoDesc,
            onTap: () async {
              LoadingOverlay.show(context, message: loc.pdfConverting);
              try {
                final folderId =
                    ref.read(folderNotifierProvider).activeFolderId;
                final repo = ref.read(scannerRepositoryProvider);
                await DocumentImportService(repo).importPdf(folderId);
                ref.read(documentNotifierProvider.notifier).loadDocuments();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.pdfPagesConvertedSuccessfully)),
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
            title: loc.aiTranscription,
            description: loc.aiTranscriptionDesc,
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
            title: loc.mediaConverter,
            description: loc.mediaConverterDesc,
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
            title: loc.qrBarcodeScan,
            description: loc.qrBarcodeScanDesc,
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
            title: loc.imageToText,
            description: loc.imageToTextDesc,
            onTap: () async {
              LoadingOverlay.show(context, message: loc.analyzingText);
              try {
                final success =
                    await FormatConversionService.extractTextToTxt();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.textFileCreated)));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${loc.error}: $e')));
                }
              } finally {
                if (context.mounted) LoadingOverlay.hide(context);
              }
            },
          ),
          _buildToolCard(
            context,
            icon: CupertinoIcons.lock_shield,
            color: Colors.redAccent,
            title: loc.pdfEncrypt,
            description: loc.pdfEncryptDesc,
            onTap: () {
              _showPasswordDialog(context, loc);
            },
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, AppLocalizations loc) {
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
