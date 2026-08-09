import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfPath,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfController _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfController(
      document: PdfDocument.openFile(widget.pdfPath),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PdfPageNumber(
            controller: _pdfController,
            builder: (_, loadingState, page, pagesCount) => Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '$page / ${pagesCount ?? 0}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: PdfView(
        controller: _pdfController,
        scrollDirection: Axis.vertical,
        pageSnapping: false,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (page) {
          // You can handle page changes here if needed
        },
      ),
    );
  }
}
