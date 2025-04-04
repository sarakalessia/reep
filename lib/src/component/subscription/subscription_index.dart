import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/plan_controller/plan_controller.dart';
import 'package:repathy/src/theme/styles.dart';

class SubscriptionIndexItem extends ConsumerWidget {
  const SubscriptionIndexItem({super.key, required this.index, this.margin = 0});

  final int index;
  final double margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlanIndex = ref.watch(currentPlanIndexProvider);

    return GestureDetector(
      onTap: () => ref.read(currentPlanIndexProvider.notifier).newIndex(index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: margin),
        width: 26,
        height: 7,
        decoration: BoxDecoration(
          color: currentPlanIndex == index ? RepathyStyle.primaryColor : RepathyStyle.lightPrimaryColor,
          borderRadius: BorderRadius.circular(6.5),
        ),
      ),
    );
  }
}
