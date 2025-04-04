import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/plan_controller/plan_controller.dart';
import 'package:repathy/src/theme/styles.dart';

class SubscriptionSelectionButton extends ConsumerWidget {
  const SubscriptionSelectionButton({super.key, required this.left, required this.top, required this.right, required this.bottom});

  final double left;
  final double top;
  final double right;
  final double bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlanPageModel = ref.watch(currentPlanPageModelProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: ElevatedButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RepathyStyle.standardRadius),
                side: currentPlanPageModel!.isSelected
                    ? BorderSide(color: RepathyStyle.primaryColor)
                    : BorderSide(color: RepathyStyle.backgroundColor, width: 1.5),
              ),
            ),
            backgroundColor:
                WidgetStateProperty.all<Color>(currentPlanPageModel.isSelected ? RepathyStyle.lightPrimaryColor : RepathyStyle.primaryColor),
            fixedSize: WidgetStateProperty.all<Size>(Size(212, 48)),
          ),
          onPressed: () {
            // if (currentPlanPageModel.isSelected) {
            //   ref.read(filteredPlansPageControllerProvider.notifier).changeCurrentPlanToUnselected();
            // }
            ref.read(filteredPlansPageControllerProvider.notifier).changeCurrentPlanToIsSelected();
          },
          child: Text(
            currentPlanPageModel.isSelected ? 'Selezionato' : 'Seleziona',
            style: TextStyle(
              color: RepathyStyle.backgroundColor,
              fontSize: RepathyStyle.miniTextSize,
              fontWeight: RepathyStyle.standardFontWeight,
            ),
          )),
    );
  }
}
