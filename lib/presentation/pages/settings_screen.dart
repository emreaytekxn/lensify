import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/settings_provider.dart';
import '../../core/utils/security_service.dart';
import '../widgets/legal_documents_dialog.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTitle),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(loc.security,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          SwitchListTile(
            title: Text(loc.appLockPin),
            subtitle: Text(loc.appLockPinDesc),
            value: prefs.getString('realPin') != null && prefs.getString('realPin')!.isNotEmpty,
            secondary: const Icon(CupertinoIcons.lock_shield),
            onChanged: (value) async {
              if (value) {
                _showPinSetupDialog(context, isFake: false);
              } else {
                final auth = await SecurityService.authenticate(
                    reason: 'Kilidi kapatmak için doğrulama gerekiyor');
                if (auth) {
                  await prefs.remove('realPin');
                  await prefs.remove('fakePin'); // Also remove fake pin if real pin is disabled
                  if (context.mounted) {
                    (context as Element).markNeedsBuild(); // Refresh UI
                  }
                }
              }
            },
          ),
          if (prefs.getString('realPin') != null && prefs.getString('realPin')!.isNotEmpty)
            ListTile(
              leading: const Icon(CupertinoIcons.eye_slash, color: Colors.redAccent),
              title: Text(loc.fakePin),
              subtitle: Text(loc.fakePinDesc),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showPinSetupDialog(context, isFake: true);
              },
            ),
          SwitchListTile(
            title: Text(loc.requireBiometrics),
            subtitle: Text(loc.requireBiometricsDesc),
            value: settingsState.requireBiometricsOnStartup,
            secondary: const Icon(CupertinoIcons.lock_shield),
            onChanged: (value) async {
              if (value) {
                final auth = await SecurityService.authenticate(
                    reason:
                        'App kilidini aktifleştirmek için doğrulama gerekiyor');
                if (auth) {
                  ref
                      .read(settingsNotifierProvider.notifier)
                      .toggleBiometricsOnStartup();
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Doğrulama başarısız.')));
                  }
                }
              } else {
                // Disabling lock
                final auth = await SecurityService.authenticate(
                    reason: 'App kilidini kapatmak için doğrulama gerekiyor');
                if (auth) {
                  ref
                      .read(settingsNotifierProvider.notifier)
                      .toggleBiometricsOnStartup();
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(CupertinoIcons.moon),
            title: Text(loc.themeMode),
            trailing: Switch(
              value: settingsState.themeMode == ThemeMode.dark,
              onChanged: (val) {
                ref
                    .read(settingsNotifierProvider.notifier)
                    .setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.globe),
            title: Text(loc.language),
            trailing: DropdownButton<String>(
              value: settingsState.locale.languageCode,
              items: const [
                DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref
                      .read(settingsNotifierProvider.notifier)
                      .setLocale(Locale(val));
                }
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Arşivleri Göster'),
            subtitle: const Text('Ana sayfada Arşivlenenler klasörünü gösterir'),
            value: settingsState.showArchivesInHome,
            secondary: const Icon(CupertinoIcons.archivebox),
            onChanged: (val) {
              ref.read(settingsNotifierProvider.notifier).toggleShowArchivesInHome();
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(loc.legalAndDocs,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.shield),
            title: Text(loc.privacyPolicy),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => LegalDocumentsDialog.showPrivacyPolicy(context),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.doc_text),
            title: Text(loc.kvkk),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => LegalDocumentsDialog.showKVKK(context),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.info),
            title: Text(loc.termsOfUse),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => LegalDocumentsDialog.showTerms(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(CupertinoIcons.restart, color: Colors.orange),
            title: const Text('Hızlı Kurulum Ekranını Göster', style: TextStyle(color: Colors.orange)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.orange),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            },
          ),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Text(
                  'Powered by',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.withValues(alpha: 0.5),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                  ).createShader(bounds),
                  child: Text(
                    'N. Emre Aytekin',
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPinSetupDialog(BuildContext context, {required bool isFake}) {
    String newPin = '';
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isFake ? loc.fakePin : loc.appLockPin),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(isFake ? loc.fakePinSetupDesc : loc.appLockPinSetupDesc),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < newPin.length ? Colors.blue : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(9, (index) {
                      return ActionChip(
                        label: Text('${index + 1}'),
                        onPressed: () {
                          if (newPin.length < 4) {
                            setState(() => newPin += '${index + 1}');
                          }
                        },
                      );
                    })..add(
                      ActionChip(
                        label: const Icon(CupertinoIcons.delete_left, size: 18),
                        onPressed: () {
                          if (newPin.isNotEmpty) {
                            setState(() => newPin = newPin.substring(0, newPin.length - 1));
                          }
                        },
                      ),
                    )..add(
                      ActionChip(
                        label: const Text('0'),
                        onPressed: () {
                          if (newPin.length < 4) {
                            setState(() => newPin += '0');
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.cancel),
                ),
                TextButton(
                  onPressed: newPin.length == 4
                      ? () async {
                          if (isFake) {
                            await prefs.setString('fakePin', newPin);
                          } else {
                            await prefs.setString('realPin', newPin);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                            // Force rebuild of settings screen
                            (this as Element).markNeedsBuild();
                          }
                        }
                      : null,
                  child: Text(loc.save),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
