import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/utils/background_remover_service.dart';
import '../../../l10n/app_localizations.dart';
import '../save_result_screen.dart';

class BackgroundEraserScreen extends ConsumerStatefulWidget {
  const BackgroundEraserScreen({super.key});

  @override
  ConsumerState<BackgroundEraserScreen> createState() => _BackgroundEraserScreenState();
}

class _BackgroundEraserScreenState extends ConsumerState<BackgroundEraserScreen> {
  File? _selectedImage;
  File? _processedImage;
  bool _isProcessing = false;
  int _activeToolIndex = 0; // 0: Fırça, 1: Arka Plan, 2: Filtre
  bool _isEraserMode = true;
  bool _isEraserMode = true;
  double _brushSize = 20.0;
  Color _selectedBgColor = Colors.transparent;
  String _selectedFilter = 'Orijinal';

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
          _processedImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final resultFile = await BackgroundRemoverService.removeBackground(_selectedImage!);
      setState(() {
        _processedImage = resultFile;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
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

  Future<void> _saveToVault() async {
    if (_processedImage == null) return;

    final fileName = 'Arkaplan_Silinmis_${DateTime.now().millisecondsSinceEpoch}';
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SaveResultScreen(
          file: _processedImage!,
          fileType: 'image',
          defaultTitle: fileName,
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: Text(_processedImage != null ? 'Düzenleyici' : loc.backgroundEraser),
        actions: _processedImage != null
            ? [
                IconButton(icon: const Icon(CupertinoIcons.arrow_uturn_left), onPressed: () {}),
                IconButton(icon: const Icon(CupertinoIcons.arrow_uturn_right), onPressed: () {}),
                TextButton(
                  onPressed: _saveToVault,
                  child: const Text('Bitti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                )
              ]
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Canvas Area (Checkered background for transparency)
                  if (_processedImage != null)
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/checkered_bg.png'), // Placeholder or fallback
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                    ),
                  
                  Center(
                    child: _isProcessing
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CupertinoActivityIndicator(radius: 20),
                              const SizedBox(height: 16),
                              Text('Yapay zeka arka planı siliyor...',
                                  style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                            ],
                          )
                        : _processedImage != null
                            ? InteractiveViewer(
                                maxScale: 5.0,
                                child: Container(
                                  color: _selectedBgColor,
                                  child: _selectedFilter == 'Orijinal' 
                                    ? Image.file(_processedImage!)
                                    : ColorFiltered(
                                        colorFilter: _getFilterMatrix(),
                                        child: Image.file(_processedImage!),
                                      ),
                                ),
                              )
                            : _selectedImage != null
                                ? Image.file(_selectedImage!)
                                : GestureDetector(
                                    onTap: _pickImage,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(CupertinoIcons.scissors_alt,
                                            size: 80, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Düzenlenecek fotoğrafı seçin',
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
            if (_selectedImage != null && _processedImage == null && !_isProcessing)
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _processImage,
                      icon: const Icon(CupertinoIcons.wand_rays),
                      label: const Text('Arka Planı Otomatik Sil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
              ),

            // PREMIUM EDITOR TOOLBAR (Only shown when image is processed)
            if (_processedImage != null)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, -5))
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sub-tools based on selected category
                      if (_activeToolIndex == 0)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              ChoiceChip(
                                label: const Text('Sil'),
                                selected: _isEraserMode,
                                onSelected: (v) => setState(() => _isEraserMode = true),
                                selectedColor: Colors.redAccent.withValues(alpha: 0.2),
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Geri Getir'),
                                selected: !_isEraserMode,
                                onSelected: (v) => setState(() => _isEraserMode = false),
                                selectedColor: Colors.green.withValues(alpha: 0.2),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Slider(
                                  value: _brushSize,
                                  min: 5,
                                  max: 50,
                                  onChanged: (v) => setState(() => _brushSize = v),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_activeToolIndex == 1)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildBgColorBubble(Colors.transparent),
                                _buildBgColorBubble(Colors.white),
                                _buildBgColorBubble(Colors.black),
                                _buildBgColorBubble(Colors.red),
                                _buildBgColorBubble(Colors.blue),
                                _buildBgColorBubble(Colors.green),
                                _buildBgColorBubble(Colors.orange),
                              ],
                            ),
                          ),
                        )
                      else if (_activeToolIndex == 2)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterBubble('Orijinal'),
                                _buildFilterBubble('Sıcak'),
                                _buildFilterBubble('Soğuk'),
                                _buildFilterBubble('Siyah Beyaz'),
                                _buildFilterBubble('Vintage'),
                              ],
                            ),
                          ),
                        ),

                      const Divider(height: 1),
                      // Main bottom bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBottomBarItem(icon: CupertinoIcons.paintbrush, label: 'Fırça', index: 0),
                          _buildBottomBarItem(icon: CupertinoIcons.square_fill_on_square_fill, label: 'Arka Plan', index: 1),
                          _buildBottomBarItem(icon: CupertinoIcons.slider_horizontal_3, label: 'Filtreler', index: 2),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBgColorBubble(Color color) {
    final isSelected = _selectedBgColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedBgColor = color),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: isSelected ? 3 : 1),
        ),
        child: color == Colors.transparent
            ? const Icon(CupertinoIcons.nosign, size: 20, color: Colors.grey)
            : null,
      ),
    );
  }

  Widget _buildFilterBubble(String name) {
    final isSelected = _selectedFilter == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = name),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
                border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 3) : null,
              ),
              child: const Icon(CupertinoIcons.photo, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  ColorFilter _getFilterMatrix() {
    switch (_selectedFilter) {
      case 'Siyah Beyaz':
        return const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]);
      case 'Sıcak':
        return const ColorFilter.matrix([
          1.2, 0,   0,   0, 0,
          0,   1.0, 0,   0, 0,
          0,   0,   0.8, 0, 0,
          0,   0,   0,   1, 0,
        ]);
      case 'Soğuk':
        return const ColorFilter.matrix([
          0.8, 0,   0,   0, 0,
          0,   1.0, 0,   0, 0,
          0,   0,   1.2, 0, 0,
          0,   0,   0,   1, 0,
        ]);
      case 'Vintage':
        return const ColorFilter.matrix([
          0.9, 0.5, 0.1, 0, 0,
          0.3, 0.8, 0.1, 0, 0,
          0.2, 0.3, 0.5, 0, 0,
          0,   0,   0,   1, 0,
        ]);
      default:
        return const ColorFilter.mode(Colors.transparent, BlendMode.multiply);
    }
  }

  Widget _buildBottomBarItem({required IconData icon, required String label, required int index}) {
    final isSelected = _activeToolIndex == index;
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey;
    return InkWell(
      onTap: () => setState(() => _activeToolIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
