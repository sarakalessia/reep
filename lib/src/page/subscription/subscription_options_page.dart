import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/subscription/go_to_subscription_button.dart';
import 'package:repathy/src/component/subscription/subscription_option_tile.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class SubscriptionOptions extends ConsumerWidget {
  const SubscriptionOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? user = ref.watch(userControllerProvider);
    final RoleEnum? userRole = user?.role;
    final bool isTherapist = userRole == RoleEnum.therapist;
    final String title = isTherapist
        ? 'Inserisci il codice della tua licenza,\n o acquistane una con 7 giorni di prova gratuita!'
        : 'Acquista una licenza, riceverai 7 giorni\n di prova gratuita!';
    final String licenseOrSubscription = isTherapist ? 'licenza' : 'abbonamento';
    final String your = isTherapist ? 'della tua' : 'del tuo';
    final String the = isTherapist ? 'la ' : 'l\'';

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo/ios_icon_transparent.png',
                    height: RepathyStyle.extraLargeIconSize,
                    width: RepathyStyle.extraLargeIconSize,
                  ),
                  SizedBox(height: 10),
                  PageTitleText(title: 'Come accedere'),
                  SizedBox(height: 15),
                  PageDescriptionText(title: title),
                  SizedBox(height: 30),
                  SubscriptionOptionTile(index: 0, title: 'Acquista $the$licenseOrSubscription'),
                  if (userRole == RoleEnum.therapist) ...[
                    SubscriptionOptionTile(index: 1, title: 'Codice $your $licenseOrSubscription'),
                  ],
                  SizedBox(height: 130),
                  GoToSubscriptionsButton(left: 0, top: 0, right: 0, bottom: 0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
