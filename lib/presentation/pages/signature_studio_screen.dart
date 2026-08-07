import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class SignatureStudioScreen extends StatefulWidget {
  final String imagePath;
  const SignatureStudioScreen({super.key, required this.imagePath});

  @override
  State<SignatureStudioScreen> createState() => _SignatureStudioScreenState();
}

class _SignatureStudioScreenState extends State<SignatureStudioScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _applySignature() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lütfen bir imza atın')));
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final signatureBytes = await _controller.toPngBytes();
      if (signatureBytes == null) return;

      // Apply watermark/signature using `image` package
      final imageFile = File(widget.imagePath);
      final imageBytes = await imageFile.readAsBytes();

      final baseImage = img.decodeImage(imageBytes);
      final signatureImage = img.decodeImage(signatureBytes);

      if (baseImage != null && signatureImage != null) {
        // Resize signature to fit bottom right
        final resizedSig =
            img.copyResize(signatureImage, width: baseImage.width ~/ 3);

        // Composite signature onto base image
        img.compositeImage(
          baseImage,
          resizedSig,
          dstX: baseImage.width - resizedSig.width - 50,
          dstY: baseImage.height - resizedSig.height - 50,
        );

        final resultBytes = img.encodeJpg(baseImage, quality: 90);
        await imageFile.writeAsBytes(resultBytes);

        if (mounted) {
          Navigator.pop(context, true); // Return success
        }
      }
    } catch (e) {
      debugPrint("Signature error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('İmza eklenirken hata oluştu')));
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
        title: const Text('İmza Stüdyosu'),
        actions: [
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CupertinoActivityIndicator(),
            )
          else
            TextButton(
              onPressed: _applySignature,
              child: const Text('Uygula',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: const Text(
                'Aşağıdaki alana imzanızı çizin. İmzanız belgenin sağ alt köşesine eklenecektir.'),
          ),
          Expanded(
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.white,
            ),
          ),
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.clear),
                  onPressed: () => _controller.clear(),
                  tooltip: 'Temizle',
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.arrow_counterclockwise),
                  onPressed: () => _controller.undo(),
                  tooltip: 'Geri Al',
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.arrow_clockwise),
                  onPressed: () => _controller.redo(),
                  tooltip: 'İleri Al',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
