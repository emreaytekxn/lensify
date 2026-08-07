import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../core/utils/security_service.dart';
import 'dashboard_screen.dart';
import 'tools_screen.dart';

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
    // Need a tiny delay for providers to be ready if called very early, or just use ref.read
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final requiresAuth =
          ref.read(settingsNotifierProvider).requireBiometricsOnStartup;
      if (requiresAuth) {
        final auth = await SecurityService.authenticate(
            reason: 'Uygulamaya girmek için doğrulama gerekiyor');
        if (mounted) {
          setState(() {
            _isAuthenticated = auth;
            _isChecking = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isChecking = false;
          });
        }
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_on_clipboard),
            activeIcon: Icon(CupertinoIcons.doc_on_clipboard_fill),
            label: 'Belgelerim',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.wrench),
            activeIcon: Icon(CupertinoIcons.wrench_fill),
            label: 'Araçlar',
          ),
        ],
      ),
    );
  }
}
