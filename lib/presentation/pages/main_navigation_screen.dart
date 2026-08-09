import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../core/utils/security_service.dart';
import 'dashboard_screen.dart';
import 'tools_screen.dart';
import '../../l10n/app_localizations.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ToolsScreen(),
  ];

  bool _isAuthenticated = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CupertinoActivityIndicator()),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.lock_shield, size: 64),
              const SizedBox(height: 16),
              const Text('Uygulama Kilitli', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkBiometrics,
                child: const Text('Tekrar Dene'),
              )
            ],
          ),
        ),
      );
    }

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.doc_on_clipboard),
            activeIcon: const Icon(CupertinoIcons.doc_on_clipboard_fill),
            label: loc.homeTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.wrench),
            activeIcon: const Icon(CupertinoIcons.wrench_fill),
            label: loc.toolsTab,
          ),
        ],
      ),
    );
  }
}
