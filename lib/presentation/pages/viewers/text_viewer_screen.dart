import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class TextViewerScreen extends StatefulWidget {
  final String textPath;
  final String title;

  const TextViewerScreen({
    super.key,
    required this.textPath,
    required this.title,
  });

  @override
  State<TextViewerScreen> createState() => _TextViewerScreenState();
}

class _TextViewerScreenState extends State<TextViewerScreen> {
  String _content = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final file = File(widget.textPath);
      final content = await file.readAsString();
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = 'Hata: Dosya okunamadı. ($e)';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                _content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
    );
  }
}
