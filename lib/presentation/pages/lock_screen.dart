import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../main.dart';
import '../providers/core_providers.dart';
import '../providers/folder_provider.dart';
import '../providers/document_provider.dart';
import 'main_navigation_screen.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _enteredPin = '';
  bool _hasError = false;

  void _onKeyPress(String key) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += key;
        _hasError = false;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _hasError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final realPin = prefs.getString('realPin');
    final fakePin = prefs.getString('fakePin');

    if (_enteredPin == realPin) {
      await _unlock('default');
    } else if (fakePin != null && _enteredPin == fakePin) {
      await _unlock('decoy');
    } else {
      setState(() {
        _hasError = true;
        _enteredPin = '';
      });
    }
  }

  Future<void> _unlock(String dbInstanceName) async {
    await ref.read(localDataSourceProvider).initDb(dbInstanceName);
    ref.read(folderNotifierProvider.notifier).loadFolders();
    ref.read(documentNotifierProvider.notifier).loadDocuments();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  Widget _buildNumpadButton(String label, {IconData? icon, VoidCallback? onPressed}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: ElevatedButton(
            onPressed: onPressed ?? () => _onKeyPress(label),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: Theme.of(context).primaryColor,
              elevation: 2,
            ),
            child: icon != null
                ? Icon(icon, size: 28)
                : Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(CupertinoIcons.lock_shield, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 24),
            Text(
              'Uygulama Kilidi',
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Erişim sağlamak için şifrenizi girin.',
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _enteredPin.length
                        ? Colors.blueAccent
                        : Colors.grey.shade300,
                    border: _hasError ? Border.all(color: Colors.red, width: 2) : null,
                  ),
                ),
              ),
            ),
            if (_hasError)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Hatalı şifre, tekrar deneyin.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildNumpadButton('1'),
                      _buildNumpadButton('2'),
                      _buildNumpadButton('3'),
                    ],
                  ),
                  Row(
                    children: [
                      _buildNumpadButton('4'),
                      _buildNumpadButton('5'),
                      _buildNumpadButton('6'),
                    ],
                  ),
                  Row(
                    children: [
                      _buildNumpadButton('7'),
                      _buildNumpadButton('8'),
                      _buildNumpadButton('9'),
                    ],
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      _buildNumpadButton('0'),
                      _buildNumpadButton('', icon: CupertinoIcons.delete_left, onPressed: _onDelete),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
