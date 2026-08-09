import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../providers/settings_provider.dart';
import '../widgets/kawaru_text.dart';
import 'main_navigation_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _completeOnboarding() {
    prefs.setBool('isFirstLaunch', false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage(
                    title: l10n.onboardingWelcomeTitle,
                    description: l10n.onboardingWelcomeDesc,
                    icon: CupertinoIcons.infinite,
                    color: Colors.blueAccent,
                  ),
                  _buildPage(
                    title: l10n.onboardingOfflineTitle,
                    description: l10n.onboardingOfflineDesc,
                    icon: CupertinoIcons.lock_shield,
                    color: Colors.green,
                  ),
                  _buildLanguagePage(l10n),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  if (_currentPage == 2)
                    ElevatedButton(
                      onPressed: _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.startButton,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child:
                          const Text('İleri', style: TextStyle(fontSize: 16)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
      {required String title,
      required String description,
      required IconData icon,
      required Color color}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: color),
          const SizedBox(height: 40),
          KawaruText(
            title,
            textAlign: TextAlign.center,
            style:
                GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePage(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.globe, size: 100, color: Colors.purple),
          const SizedBox(height: 40),
          Text(
            l10n.onboardingLanguageTitle,
            textAlign: TextAlign.center,
            style:
                GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingLanguageDesc,
            textAlign: TextAlign.center,
            style:
                const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 40),
          ListTile(
            title: const Text('Türkçe'),
            leading: const Text('🇹🇷', style: TextStyle(fontSize: 24)),
            trailing: Localizations.localeOf(context).languageCode == 'tr'
                ? const Icon(CupertinoIcons.check_mark, color: Colors.green)
                : null,
            onTap: () {
              ref
                  .read(settingsNotifierProvider.notifier)
                  .setLocale(const Locale('tr'));
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('English'),
            leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
            trailing: Localizations.localeOf(context).languageCode == 'en'
                ? const Icon(CupertinoIcons.check_mark, color: Colors.green)
                : null,
            onTap: () {
              ref
                  .read(settingsNotifierProvider.notifier)
                  .setLocale(const Locale('en'));
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
          ),
        ],
      ),
    );
  }
}
