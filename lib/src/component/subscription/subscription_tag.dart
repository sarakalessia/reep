import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/plan_controller/plan_controller.dart';
import 'package:repathy/src/util/enum/subscription_enum.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:repathy/src/util/helper/subscription_formatter/subscription_formatter.dart';

class SubscriptionTag extends ConsumerWidget {
  const SubscriptionTag({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PlanFrequency frequency = ref.watch(currentPlanFrequencyProvider);

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: frequency.name == ref.read(subscriptionFormatterProvider.notifier).translateFrequency(title, 'it')
            ? WidgetStateProperty.all<Color>(RepathyStyle.primaryColor)
            : WidgetStateProperty.all<Color>(RepathyStyle.backgroundColor),
        fixedSize: WidgetStateProperty.all<Size>(Size(123, 25)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(RepathyStyle.lightRadius)),
        ),
      ),
      onPressed: () => ref.read(currentPlanFrequencyProvider.notifier).updateFilter(title),
      child: frequency.name == ref.read(subscriptionFormatterProvider.notifier).translateFrequency(title, 'it')
          ? Text(
              title,
              style: TextStyle(color: RepathyStyle.backgroundColor),
            )
          : Text(title),
    );
  }
}
