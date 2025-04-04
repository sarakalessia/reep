import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/controller/subscription_option_controller/subscription_option_controller.dart';
import 'package:repathy/src/theme/styles.dart';

class GoToSubscriptionsButton extends ConsumerStatefulWidget {
  const GoToSubscriptionsButton({
    super.key,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GoToSubscriptionsButtonState();
}

class _GoToSubscriptionsButtonState extends ConsumerState<GoToSubscriptionsButton> {
  @override
  Widget build(BuildContext context) {
    final bool checkIfAnySubscriptionIsSelected = ref.watch(isAnySubscriptionOptionselectedProvider);
    final int indexOfSelectedSubscriptionOption = ref.watch(indexOfSelectedSubscriptionOptionProvider);
    final bool isSubscriptionOptionLoading = ref.watch(isSubscriptionOptionLoadingProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(widget.left, widget.top, widget.right, widget.bottom),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RepathyStyle.roundedRadius),
              side: BorderSide(color: RepathyStyle.primaryColor, width: 0.5),
            ),
          ),
          backgroundColor: checkIfAnySubscriptionIsSelected
              ? WidgetStateProperty.all<Color>(RepathyStyle.primaryColor)
              : WidgetStateProperty.all<Color>(RepathyStyle.backgroundColor),
          fixedSize: WidgetStateProperty.all<Size>(Size(RepathyStyle.buttonWidthStandard, RepathyStyle.buttonHeightStandard)),
        ),
        onPressed: () async {
          if (!checkIfAnySubscriptionIsSelected) return;
          ref.read(isSubscriptionOptionLoadingProvider.notifier).setToLoading();
          switch (indexOfSelectedSubscriptionOption) {
            case 0:
              ref.read(goRouterProvider).go('/subscription');
            case 1:
              // Let user enter the license code he got from his boss
              // Link user to the existing license, and proceed to the next page
              break;
            default:
          }
          ref.read(isSubscriptionOptionLoadingProvider.notifier).setToNotLoading();
        },
        child: isSubscriptionOptionLoading
            ? CircularProgressIndicator()
            : Text(
                'Continua',
                style: TextStyle(
                  color: checkIfAnySubscriptionIsSelected ? RepathyStyle.backgroundColor : RepathyStyle.primaryColor,
                  fontSize: RepathyStyle.standardTextSize,
                  fontWeight: RepathyStyle.standardFontWeight,
                ),
              ),
      ),
    );
  }
}
