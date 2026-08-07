import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../core/utils/security_service.dart';
import '../widgets/legal_documents_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Uygulama Açılışında FaceID / TouchID İste'),
            subtitle:
                const Text('Uygulamaya her girdiğinizde doğrulama istenir.'),
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
            title: const Text('Karanlık / Aydınlık Mod'),
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
            title: const Text('Dil / Language'),
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
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Yasal ve Hukuki',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.shield),
            title: const Text('Gizlilik Politikası'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => LegalDocumentsDialog.showPrivacyPolicy(context),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.doc_text),
            title: const Text('KVKK Aydınlatma Metni'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => LegalDocumentsDialog.showKVKK(context),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.info),
            title: const Text('Kullanım Koşulları'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => LegalDocumentsDialog.showTerms(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
