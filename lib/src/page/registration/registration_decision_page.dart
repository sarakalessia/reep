import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/util/enum/element_size_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class RegistrationDecisionPage extends ConsumerWidget {
  const RegistrationDecisionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
              child: Image.asset(
                'assets/logo/ios_icon_transparent.png',
                width: 250,
                height: 233,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: RepathyStyle.slightlyDarkerBackgroundColor,
                borderRadius: BorderRadius.circular(RepathyStyle.roundedRadius),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000), // #0000001A
                    offset: Offset(0, 0),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Benvenuto in Repathy!\n',
                            style: TextStyle(
                              color: RepathyStyle.defaultTextColor,
                              fontSize: RepathyStyle.standardTextSize,
                              fontWeight: RepathyStyle.lightFontWeight,
                            ),
                          ),
                          TextSpan(
                            text: 'Scegli l’opzione con la quale\n',
                            style: TextStyle(
                              color: RepathyStyle.defaultTextColor,
                              fontSize: RepathyStyle.standardTextSize,
                              fontWeight: RepathyStyle.lightFontWeight,
                            ),
                          ),
                          TextSpan(
                            text: 'accedere',
                            style: TextStyle(
                              color: RepathyStyle.defaultTextColor,
                              fontSize: RepathyStyle.standardTextSize,
                              fontWeight: RepathyStyle.lightFontWeight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    PrimaryButton(
                      size: ElementSize.small,
                      isRounded: true,
                      text: AppLocalizations.of(context)!.areYouATherapist,
                      onPressed: () => ref.read(goRouterProvider).go('/register/therapist'),
                    ),
                    PrimaryButton(
                      isLightSecondary: true,
                      size: ElementSize.small,
                      isRounded: true,
                      text: AppLocalizations.of(context)!.areYouAPatient,
                      onPressed: () => ref.read(goRouterProvider).go('/register/patient'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
