import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class LoadingOverlay {
  static void show(
    BuildContext context, {
    String message = 'İşleniyor...',
    bool showTimer = false,
    String? infoText,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) {
        return _LoadingDialog(
          message: message,
          showTimer: showTimer,
          infoText: infoText,
          onCancel: onCancel,
        );
      },
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

class _LoadingDialog extends StatefulWidget {
  final String message;
  final bool showTimer;
  final String? infoText;
  final VoidCallback? onCancel;

  const _LoadingDialog({
    required this.message,
    required this.showTimer,
    this.infoText,
    this.onCancel,
  });

  @override
  State<_LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<_LoadingDialog> {
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.showTimer) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _seconds++;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.blueAccent,
                size: 60,
              ),
              const SizedBox(height: 24),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              if (widget.infoText != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.infoText!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
                    color: Colors.grey,
                  ),
                ),
              ],
              if (widget.showTimer) ...[
                const SizedBox(height: 12),
                Text(
                  'Geçen Süre: $_formattedTime',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                    color: Colors.grey,
                  ),
                ),
              ],
              if (widget.onCancel != null) ...[
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.cancel_outlined,
                      color: Colors.redAccent),
                  label: const Text('İptal Et',
                      style: TextStyle(color: Colors.redAccent)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
