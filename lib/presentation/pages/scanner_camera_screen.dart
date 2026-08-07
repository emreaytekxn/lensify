import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/camera_service.dart';
import '../../core/utils/image_processing_service.dart';
import '../../domain/entities/document_page.dart';
import '../../domain/entities/filter_type.dart';
import '../providers/core_providers.dart';
import 'filter_screen.dart';

class ScannerCameraScreen extends ConsumerStatefulWidget {
  final int? targetDocumentId; // If adding to existing document

  const ScannerCameraScreen({super.key, this.targetDocumentId});

  @override
  ConsumerState<ScannerCameraScreen> createState() => _ScannerCameraScreenState();
}

class _ScannerCameraScreenState extends ConsumerState<ScannerCameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  FlashMode _flashMode = FlashMode.off;
  final ImagePicker _picker = ImagePicker();

  bool _isIdCardMode = false;
  bool _isBatchMode = false;
  int _batchCount = 0;
  String? _idCardFrontPath;
  bool _isProcessingIdCard = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.max, // High quality for documents
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    if (_controller == null) return;
    
    setState(() {
      if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.always;
      } else if (_flashMode == FlashMode.always) {
        _flashMode = FlashMode.auto;
      } else {
        _flashMode = FlashMode.off;
      }
    });
    
    await _controller!.setFlashMode(_flashMode);
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    try {
      final XFile photo = await _controller!.takePicture();
      
      if (_isIdCardMode) {
        if (_idCardFrontPath == null) {
          // Front captured
          setState(() {
            _idCardFrontPath = photo.path;
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ön yüz çekildi. Şimdi arka yüzü çekin.')));
        } else {
          // Back captured, combine them
          setState(() {
            _isProcessingIdCard = true;
          });
          
          final combinedPath = await ImageProcessingService.combineIdCard(_idCardFrontPath!, photo.path);
          
          setState(() {
            _isProcessingIdCard = false;
            _idCardFrontPath = null;
          });
          
          if (combinedPath != null) {
            await _processSelectedImage(combinedPath);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kimlik birleştirilemedi.')));
          }
        }
      } else {
        // Normal document mode
        await _processSelectedImage(photo.path);
      }
    } catch (e) {
      debugPrint("Take Picture Error: $e");
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        await _processSelectedImage(photo.path);
      }
    } catch (e) {
      debugPrint("Gallery Error: $e");
    }
  }

  Future<void> _processSelectedImage(String path) async {
    // 1. Edge Detection & Perspective Crop using image_cropper
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100, // Keep max quality for documents
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Belgeyi Kırp',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Belgeyi Kırp',
          cancelButtonTitle: 'İptal',
          doneButtonTitle: 'Bitti',
        ),
      ],
    );

    if (croppedFile != null) {
      // 2. Navigate to Filter Screen
      if (!mounted) return;
      
      if (_isBatchMode && widget.targetDocumentId != null) {
        // Just save to the current document and continue
        final repo = ref.read(scannerRepositoryProvider);
        await repo.addPageToDocument(DocumentPage(
          documentId: widget.targetDocumentId!,
          originalImagePath: croppedFile.path,
          processedImagePath: croppedFile.path, // Assuming no filter in rapid batch mode for simplicity, or we can apply default
          pageIndex: 0, // It will be ordered by repo or just appended
          appliedFilter: FilterType.original,
          createdAt: DateTime.now(),
        ));
        setState(() {
          _batchCount++;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sayfa eklendi ($_batchCount)')));
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => FilterScreen(
              imagePath: croppedFile.path,
              targetDocumentId: widget.targetDocumentId,
            ),
          ),
        );
      }
    }
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return CupertinoIcons.bolt_slash_fill;
      case FlashMode.always:
        return CupertinoIcons.bolt_fill;
      case FlashMode.auto:
        return CupertinoIcons.bolt_badge_a_fill;
      default:
        return CupertinoIcons.bolt_slash_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CupertinoActivityIndicator(color: Colors.white)),
      );
    }

    final size = MediaQuery.of(context).size;
    final scale = size.aspectRatio * _controller!.value.aspectRatio;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Center(
            child: Transform.scale(
              scale: scale < 1 ? 1 / scale : scale,
              child: CameraPreview(_controller!),
            ),
          ),
          
          // Top Controls
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.xmark, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    IconButton(
                      icon: Icon(_getFlashIcon(), color: Colors.white, size: 28),
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24, top: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mode Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoSegmentedControl<int>(
                        groupValue: _isBatchMode ? 2 : (_isIdCardMode ? 1 : 0),
                        children: const {
                          0: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Belge')),
                          1: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Kimlik')),
                          2: Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Çoklu')),
                        },
                        onValueChanged: (val) {
                          setState(() {
                            if (val == 0) {
                              _isIdCardMode = false;
                              _isBatchMode = false;
                            } else if (val == 1) {
                              _isIdCardMode = true;
                              _isBatchMode = false;
                              _idCardFrontPath = null;
                            } else {
                              _isIdCardMode = false;
                              _isBatchMode = true;
                              _batchCount = 0;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Gallery Button
                      GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(CupertinoIcons.photo, color: Colors.white),
                    ),
                  ),
                  
                      // Capture Button
                      GestureDetector(
                        onTap: _isProcessingIdCard ? null : _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isIdCardMode && _idCardFrontPath != null ? Colors.orange : Colors.white, 
                              width: 4
                            ),
                          ),
                          child: Center(
                            child: _isProcessingIdCard
                                ? const CupertinoActivityIndicator()
                                : Container(
                                    width: 66,
                                    height: 66,
                                    decoration: BoxDecoration(
                                      color: _isIdCardMode && _idCardFrontPath != null ? Colors.orange : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      
                      // Empty space to balance the row
                      const SizedBox(width: 50),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
