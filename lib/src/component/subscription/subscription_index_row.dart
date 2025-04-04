import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/subscription/subscription_index.dart';
import 'package:repathy/src/controller/plan_controller/plan_controller.dart';

class SubscriptionIndexRow extends ConsumerWidget {
  const SubscriptionIndexRow({super.key, required this.top, required this.right, required this.bottom, required this.left});

  final double left;
  final double top;
  final double right;
  final double bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredSubscriptionPageController = ref.watch(filteredPlansPageControllerProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < filteredSubscriptionPageController.length; i++) SubscriptionIndexItem(index: i, margin: 1),
        ],
      ),
    );
  }
}
