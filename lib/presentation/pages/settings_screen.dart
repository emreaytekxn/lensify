import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../../core/utils/security_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
            subtitle: const Text('Uygulamaya her girdiğinizde doğrulama istenir.'),
            value: settingsState.requireBiometricsOnStartup,
            secondary: const Icon(CupertinoIcons.lock_shield),
            onChanged: (value) async {
              if (value) {
                final auth = await SecurityService.authenticate(reason: 'App kilidini aktifleştirmek için doğrulama gerekiyor');
                if (auth) {
                  ref.read(settingsNotifierProvider.notifier).toggleBiometricsOnStartup();
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doğrulama başarısız.')));
                  }
                }
              } else {
                // Disabling lock
                final auth = await SecurityService.authenticate(reason: 'App kilidini kapatmak için doğrulama gerekiyor');
                if (auth) {
                  ref.read(settingsNotifierProvider.notifier).toggleBiometricsOnStartup();
                }
              }
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
