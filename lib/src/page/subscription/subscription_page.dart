import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/subscription/subscription_box.dart';
import 'package:repathy/src/component/subscription/choose_subscription_button.dart';
import 'package:repathy/src/component/subscription/subscription_header.dart';
import 'package:repathy/src/component/subscription/subscription_index_row.dart';
import 'package:repathy/src/component/subscription/subscription_tag.dart';
import 'package:repathy/src/controller/plan_controller/plan_controller.dart';
import 'package:repathy/src/controller/purchase_controller/purchase_controller.dart';
import 'package:repathy/src/model/component_models/subscription_page_model/subscription_page_model.dart';

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PlansPageModel>> asyncPlanPageList = ref.watch(asyncPlanPageControllerProvider);
    final AsyncValue<PurchaseDetails> purchaseStream = ref.watch(purchaseStreamProvider);

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SubscriptionHeader(),
              purchaseStream.when(
                data: (PurchaseDetails purchaseDetails) {
                  if (purchaseDetails.status == PurchaseStatus.pending || purchaseDetails.status == PurchaseStatus.purchased) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return PrimaryButton(
                    text: 'Riprova',
                    onPressed: () => ref.read(goRouterProvider).go('/subscription-options'),
                  );
                },
                loading: () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SubscriptionTag(title: 'mensile'),
                        SizedBox(width: 10),
                        SubscriptionTag(title: 'annuale'),
                      ],
                    ),
                    SizedBox(height: 10),
                    asyncPlanPageList.when(
                      data: (_) => SubscriptionBox(),
                      loading: () => Center(child: CircularProgressIndicator()),
                      error: (error, _) => Text('Error: $error'),
                    ),
                    SubscriptionIndexRow(left: 0, top: 20, right: 0, bottom: 0),
                    SizedBox(height: 40),
                    ChooseSubscriptionButton(left: 0, top: 0, right: 0, bottom: 0),
                  ],
                ),
                error: (error, _) => Text('Error: $error'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
