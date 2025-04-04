import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/controller/plan_controller/plan_controller.dart';
import 'package:repathy/src/controller/subscription_controller/subscription_controller.dart';
import 'package:repathy/src/model/component_models/subscription_page_model/subscription_page_model.dart';
import 'package:repathy/src/model/data_models/plan_model/plan_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/repository/purchase_repository/purchase_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

part 'purchase_controller.g.dart';

@riverpod
class PurchaseStream extends _$PurchaseStream {
  @override
  Stream<PurchaseDetails> build() async* {
    final InAppPurchase iap = ref.read(inAppPurchaseInstanceProvider);
    final StreamController<PurchaseDetails> controller = StreamController<PurchaseDetails>();
    final PlansPageModel? currentPlanPageModel = ref.watch(currentPlanPageModelProvider);
    final PlanModel? currentPlan = currentPlanPageModel?.subscriptionPlan;
    // final AppleReceiptResponseModel? appleReceipt = ref.listen(appleReceiptControllerProvider, (_, __) {}).read();

    if (currentPlan == null) {
      controller.addError('Controller: purchaseUpdatesStream currentPlan is null');
      controller.close();
      return;
    }

    final subscription = iap.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) async {
        for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
          if (!controller.isClosed) controller.add(purchaseDetails);
          debugPrint('Controller: purchaseUpdatesStream purchaseDetails is $purchaseDetails');
          switch (purchaseDetails.status) {
            case PurchaseStatus.restored:
            case PurchaseStatus.purchased:
              _onPurchasedOrRestored(purchaseDetails, iap, currentPlan);
            case PurchaseStatus.error:
              _onError(purchaseDetails, iap);
            case PurchaseStatus.pending:
              _onPending(purchaseDetails, iap);
            case PurchaseStatus.canceled:
              _onCanceled(purchaseDetails, iap);
          }
        }
      },
      onError: (error) {
        debugPrint('Controller: purchaseUpdatesStream error is $error');
        controller.addError(error);
        controller.close();
      },
      onDone: () => controller.close(),
    );

    ref.onDispose(() {
      ref.invalidate(currentPlanPageModelProvider);
      subscription.cancel();
      controller.close();
    });

    yield* controller.stream;
  }

  _onPurchasedOrRestored(PurchaseDetails purchaseDetails, InAppPurchase iap, PlanModel currentPlan) async {
    debugPrint('Controller: purchaseUpdatesStream purchased PurchaseStatus is ${purchaseDetails.status}');

    final String receiptData = purchaseDetails.verificationData.serverVerificationData;
    debugPrint('Controller: purchaseUpdatesStream receiptData is $receiptData');
    ResultModel<bool> result = ResultModel<bool>(error: 'Controller: purchaseUpdatesStream result is null');

    if (Platform.isIOS) {
      result = await ref.read(purchaseRepositoryProvider.notifier).verifyAppleReceipt(receiptData, currentPlan);
    }

    if (Platform.isAndroid) {
      result = await ref.read(purchaseRepositoryProvider.notifier).verifyGooglePlayReceipt(purchaseDetails, currentPlan);
    }

    debugPrint('Controller: purchaseUpdatesStream result is $result');
    final bool? resultData = result.data;
    debugPrint('Controller: purchaseUpdatesStream resultData is $result');
    debugPrint('Controller: purchaseUpdatesStream resultData is $resultData');
  // if (resultData == true) {
  //   debugPrint('Controller: purchaseUpdatesStream resultData is true');
  //   // ref.read(appleReceiptControllerProvider.notifier).setAppleReceipt(resultData);
  //   await ref.read(subscriptionControllerProvider.notifier).handleSubscriptionChange(plan: currentPlan);
  // }
    if (purchaseDetails.pendingCompletePurchase) {
      debugPrint('Controller: purchaseUpdatesStream Completing purchase for ${purchaseDetails.productID}');
      await iap.completePurchase(purchaseDetails);
      debugPrint('Controller: purchaseUpdatesStream Purchase COMPLETED for ${purchaseDetails.productID}');
      // add 
      await ref.read(subscriptionControllerProvider.notifier).handleSubscriptionChange(plan: currentPlan);
    }
    ref.read(goRouterProvider).go('/');
  }

  _onError(PurchaseDetails purchaseDetails, InAppPurchase iap) async {
    debugPrint('Controller: purchaseUpdatesStream error PurchaseStatus is ${purchaseDetails.status}');
    if (purchaseDetails.pendingCompletePurchase) {
      debugPrint('Controller: purchaseUpdatesStream Completing purchase (error case) for ${purchaseDetails.productID}');
      await iap.completePurchase(purchaseDetails);
      debugPrint('Controller: purchaseUpdatesStream Purchase COMPLETED (error case) for ${purchaseDetails.productID}');
    }
    ref.invalidateSelf();
  }

  _onPending(PurchaseDetails purchaseDetails, InAppPurchase iap) async {
    debugPrint('Controller: purchaseUpdatesStream pending PurchaseStatus is ${purchaseDetails.status}');
    await iap.completePurchase(purchaseDetails);
  }

  _onCanceled(PurchaseDetails purchaseDetails, InAppPurchase iap) async {
    debugPrint('Controller: purchaseUpdatesStream canceled PurchaseStatus is ${purchaseDetails.status}');
    if (purchaseDetails.pendingCompletePurchase) {
      debugPrint('Controller: purchaseUpdatesStream Completing purchase (cancel case) for ${purchaseDetails.productID}');
      await iap.completePurchase(purchaseDetails);
      debugPrint('Controller: purchaseUpdatesStream Purchase COMPLETED (cancel case) for ${purchaseDetails.productID}');
    }
    ref.invalidateSelf();
  }
}
