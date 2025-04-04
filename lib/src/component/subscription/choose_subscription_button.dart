import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/plan_controller/plan_controller.dart';
import 'package:repathy/src/model/component_models/subscription_page_model/subscription_page_model.dart';
import 'package:repathy/src/repository/purchase_repository/purchase_repository.dart';
import 'package:repathy/src/theme/styles.dart';

class ChooseSubscriptionButton extends ConsumerWidget {
  const ChooseSubscriptionButton({super.key, required this.left, required this.top, required this.right, required this.bottom});

  final double left;
  final double top;
  final double right;
  final double bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool checkIfAnyPlanIsSelected = ref.watch(checkIfAnyPlanIsSelectedProvider);
    final PlansPageModel? currentPlanPageModel = ref.watch(currentPlanPageModelProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RepathyStyle.roundedRadius),
              side: BorderSide(color: RepathyStyle.primaryColor, width: 0.5),
            ),
          ),
          backgroundColor: checkIfAnyPlanIsSelected
              ? WidgetStateProperty.all<Color>(RepathyStyle.primaryColor)
              : WidgetStateProperty.all<Color>(RepathyStyle.backgroundColor),
          fixedSize: WidgetStateProperty.all<Size>(Size(RepathyStyle.buttonWidthStandard, RepathyStyle.buttonHeightStandard)),
        ),
        onPressed: () async {
          if (!checkIfAnyPlanIsSelected) return;
          debugPrint('View: ChooseSubscriptionButton: ${currentPlanPageModel!.subscriptionPlan}');
          await ref.read(purchaseRepositoryProvider.notifier).purchaseProduct(plan: currentPlanPageModel.subscriptionPlan);
        },
        child: Text(
          'Continua',
          style: TextStyle(
            color: checkIfAnyPlanIsSelected ? RepathyStyle.backgroundColor : RepathyStyle.primaryColor,
            fontSize: RepathyStyle.standardTextSize,
            fontWeight: RepathyStyle.standardFontWeight,
          ),
        ),
      ),
    );
  }
}
