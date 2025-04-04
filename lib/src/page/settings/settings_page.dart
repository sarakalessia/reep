import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/component/settings/delete-profile.dart';
import 'package:repathy/src/component/settings/settings_tile.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:repathy/src/util/helper/environment_config/environment_config.dart';
import 'package:repathy/src/util/helper/url_launcher/url_launcher.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final privacyPolicyUrl = ref.read(environmentConfigProvider).requireValue['PRIVACY_POLICY_URL'];
    final termsOfServiceUrl = ref.read(environmentConfigProvider).requireValue['TERMS_OF_SERVICE_URL'];

    debugPrint('View: SettingsPage: privacyPolicyUrl: $privacyPolicyUrl');
    debugPrint('View: SettingsPage: termsOfServiceUrl: $termsOfServiceUrl');

    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Impostazioni',
                style: TextStyle(
                  fontSize: RepathyStyle.largeTextSize,
                  color: RepathyStyle.defaultTextColor,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          SettingsTile(
              title: 'Licenza', onTap: () => ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 1, subPage: PageEnum.licenses)),
          SettingsTile(title: 'Politica sulla privacy', onTap: () => ref.read(launchBrowserUrlProvider(privacyPolicyUrl ?? ''))),
          SettingsTile(title: 'Termini di servizio', onTap: () => ref.read(launchBrowserUrlProvider(termsOfServiceUrl ?? ''))),
          SettingsTile(
              title: 'Logout',
              onTap: () {
                ref.read(goRouterProvider).go('/login');
                ref.read(userControllerProvider.notifier).signOut();
              }),
          SettingsTile(
              title: 'Elimina account',
              onTap: () {
                // CALL A DIALOG TO CONFIRM THE DELETION OF THE ACCOUNT
                // DELETE BOTH AUTH AND FIRESTORE DATA, QUERY HIS ID IN OTHER COLLECTIONS AND DELETE IT
                showModalBottomSheet(
                  context: context,
                  builder: (context) => DeleteProfileSheet(),
                );
              }),
        ],
      ),
    );
  }
}
