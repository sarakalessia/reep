import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:repathy/src/component/subscription/subscription_selection_button.dart';
import 'package:repathy/src/controller/plan_controller/plan_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/component_models/subscription_page_model/subscription_page_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/util/enum/subscription_enum.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:repathy/src/util/helper/subscription_formatter/subscription_formatter.dart';

class SubscriptionBox extends ConsumerWidget {
  const SubscriptionBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? currentUser = ref.watch(userControllerProvider);
    final PlansPageModel? currentPlanPageModel = ref.watch(currentPlanPageModelProvider);
    final List<PlansPageModel> filteredSubscriptionPageController = ref.watch(filteredPlansPageControllerProvider);
    final int currentSubscriptionIndex = ref.watch(currentPlanIndexProvider);
    final RoleEnum? userRole = currentUser?.role;
    final bool isTherapist = userRole == RoleEnum.therapist;

    final String formattedPrice = NumberFormat.currency(
      locale: 'de_CH',
      symbol: '',
      decimalDigits: 2,
    ).format(currentPlanPageModel!.subscriptionPlan.countryPrices[1].price);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final int length = filteredSubscriptionPageController.length;
        if (details.primaryVelocity! > 0 && currentSubscriptionIndex > 0) {
          ref.read(currentPlanIndexProvider.notifier).newIndex(currentSubscriptionIndex - 1);
        } else if (details.primaryVelocity! < 0 && currentSubscriptionIndex < length - 1) {
          ref.read(currentPlanIndexProvider.notifier).newIndex(currentSubscriptionIndex + 1);
        }
      },
      child: Container(
        width: 260,
        height: 314,
        decoration: BoxDecoration(
          color: RepathyStyle.primaryColor,
          borderRadius: BorderRadius.circular(RepathyStyle.roundedRadius),
          boxShadow: [
            BoxShadow(
              color: Color(0x29000000), // #00000029
              offset: Offset(0, 13.8),
              blurRadius: 42.47,
            ),
            BoxShadow(
              color: Color(0x12000000), // #00000012
              offset: Offset(0, 6.37),
              blurRadius: 21.23,
            ),
            BoxShadow(
              color: Color(0x0D000000), // #0000000D
              offset: Offset(0, 2.65),
              blurRadius: 4.25,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ref
                        .read(subscriptionFormatterProvider.notifier)
                        .convertV1PlanNamesToShowableNames(currentPlanPageModel.subscriptionPlan.name, isTherapist),
                    style: TextStyle(
                      color: RepathyStyle.backgroundColor,
                      fontSize: RepathyStyle.standardTextSize,
                      fontWeight: RepathyStyle.boldFontWeight,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '$formattedPrice /',
                        style: TextStyle(
                          color: RepathyStyle.backgroundColor,
                          fontSize: RepathyStyle.extraLargeTextSize,
                          fontWeight: RepathyStyle.boldFontWeight,
                        ),
                      ),
                      Text(
                        currentPlanPageModel.subscriptionPlan.frequency == PlanFrequency.monthly ? 'mese' : 'anno',
                        style: TextStyle(
                          color: RepathyStyle.backgroundColor,
                          fontSize: RepathyStyle.miniTextSize,
                          fontWeight: RepathyStyle.standardFontWeight,
                        ),
                      ),
                    ],
                  ),
                  if (currentPlanPageModel.subscriptionPlan.frequency == PlanFrequency.yearly)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Risparmia un mese gratis\n',
                            style: TextStyle(
                              color: RepathyStyle.backgroundColor,
                              fontSize: RepathyStyle.miniTextSize,
                              fontWeight: RepathyStyle.standardFontWeight,
                            ),
                          ),
                          TextSpan(
                            text: isTherapist ? 'con la licenza annuale!' : 'con l\'abbonamento annuale!',
                            style: TextStyle(
                              color: RepathyStyle.backgroundColor,
                              fontSize: RepathyStyle.miniTextSize,
                              fontWeight: RepathyStyle.standardFontWeight,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SubscriptionSelectionButton(left: 0, top: 10, right: 0, bottom: 20),
          ],
        ),
      ),
    );
  }
}
