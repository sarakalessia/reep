import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/plan_model/plan_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:repathy/src/model/data_models/subscription_model/subscription_model.dart';
import 'package:repathy/src/util/enum/subscription_enum.dart';
import 'package:repathy/src/repository/subscription_repository/subscription_repository.dart';

part 'subscription_controller.g.dart';

@Riverpod(keepAlive: true)
class SubscriptionController extends _$SubscriptionController {
  @override
  (SubscriptionModel? patient, SubscriptionModel? therapist) build() => (null, null);

  updateCachedSubscription(SubscriptionModel? newSubscription) {
    if (newSubscription == null) return;
    if (newSubscription.type == PlanType.patient) state = (newSubscription, state.$2);
    if (newSubscription.type == PlanType.therapist) state = (state.$1, newSubscription);
  }

  cleanCachedSubscription(PlanType planType) {
    if (planType == PlanType.patient) state = (null, state.$2);
    if (planType == PlanType.therapist) state = (state.$1, null);
  }

  cleanAllCachedSubscriptions() => state = (null, null);

  // UPDATE

  // THIS GUARANTEES THE USER HAS NOT ONLY ADDED A NEW SUBSCRIPTION BUT ALSO REMOVED THE OLD ONE
  Future<bool> handleSubscriptionChange({required PlanModel plan}) async {
    debugPrint('Controller: handleSubscriptionChange is called with plan: $plan');
    final PlanType planType = plan.type;
    final UserModel? user = ref.read(userControllerProvider);

    if (user == null) return false;

    try {
      if (planType == PlanType.therapist && user.therapistSubscriptionId != null) {
        await expireSubscription(planType);
        debugPrint('Controller: handleSubscriptionChange expired therapist subscription id is ${user.therapistSubscriptionId}');
      }

      if (planType == PlanType.patient && user.patientSubscriptionId != null) {
        await expireSubscription(planType);
        debugPrint('Controller: handleSubscriptionChange expired patient subscription id is ${user.patientSubscriptionId}');
      }

      // final AppleReceiptResponseModel? appleReceipt = ref.read(appleReceiptControllerProvider);

      final subscriptionResult =
          await ref.read(subscriptionRepositoryProvider.notifier).createNewSubscription(userId: user.id!, plan: plan);
      final subscriptionModel = subscriptionResult.data;
      updateCachedSubscription(subscriptionModel);

      return true;
    } catch (e) {
      debugPrint('Controller: handleSubscriptionChange error is $e');
      return false;
    }
  }

  // TODO: FIX THIS
  Future<void> expireSubscription(PlanType? planType) async {
    final user = ref.read(userControllerProvider);
    PlanType chosenPlanType = PlanType.unknown;
    if (user == null) return;
    if (planType == null) {
      final patientSubscriptionId = user.patientSubscriptionId;
      // final therapistSubscriptionId = user.therapistSubscriptionId;
      if (patientSubscriptionId != null) chosenPlanType = PlanType.patient;
    }
    if (planType != null) chosenPlanType = planType;
    await ref.read(subscriptionRepositoryProvider.notifier).expireSubscription(user, chosenPlanType);
    await ref.read(userControllerProvider.notifier).syncCachedUserWithDatabase();
  }

  // Used to suspend unpaid subscriptions
  Future<bool> suspendSubscription({required String userId, required SubscriptionModel userSubscription}) async {
    try {
      final suspendedSubscription = userSubscription.copyWith(status: SubscriptionStatus.suspended);
      await ref.read(subscriptionRepositoryProvider.notifier).updateSubscription(suspendedSubscription);
      return true;
    } catch (e) {
      debugPrint('Controller: suspendSubscription error is: $e');
      return false;
    }
  }

  // Deals with the reactivation of a suspended subscription
  Future<bool> reactivateSubscription({required String userId, required SubscriptionModel userSubscription}) async {
    try {
      final activeSubscription = userSubscription.copyWith(status: SubscriptionStatus.active);
      await ref.read(subscriptionRepositoryProvider.notifier).updateSubscription(activeSubscription);
      return true;
    } catch (e) {
      debugPrint('Controller: reactivateSubscription error is: $e');
      return false;
    }
  }
}

// GET SUBSCRIPTION HISTORY FOR THE CURRENT USER

@riverpod
Future<ResultModel<List<SubscriptionModel>>> getSubscriptionHistory(Ref ref) async {
  UserModel? user = ref.read(userControllerProvider);
  if (user == null) {
    final userResult = await ref.read(getCurrentUserModelFromFirestoreProvider.future);
    user = userResult.data;
    if (user == null) return ResultModel(error: 'Controller: getSubscriptionHistory error getting user');
  }

  return await ref.read(subscriptionRepositoryProvider.notifier).getSubscriptionHistory(user);
}

@riverpod
FutureOr<(ResultModel<SubscriptionModel>, ResultModel<SubscriptionModel>)> getCurrentUserSubscription(Ref ref) async {
  final UserModel? userModel = ref.read(userControllerProvider);
  if (userModel == null) {
    return (
      ResultModel<SubscriptionModel>(error: 'Controller: getCurrentUserSubscription error getting user'),
      ResultModel<SubscriptionModel>(error: 'Controller: getCurrentUserSubscription error getting user')
    );
  }
  // TODO: ADD AN APPLE RECEIPT VERIFICATION HERE TO CHECK FOR UNPAID, EXPIRED, ETC.
  final subscriptionResult = await ref.read(subscriptionRepositoryProvider.notifier).getCurrentUserSubscription(userModel);
  final patientSubscriptionModel = subscriptionResult.$1;
  final therapistSubscriptionModel = subscriptionResult.$2;
  ref.read(subscriptionControllerProvider.notifier).updateCachedSubscription(patientSubscriptionModel.data);
  ref.read(subscriptionControllerProvider.notifier).updateCachedSubscription(therapistSubscriptionModel.data);
  return subscriptionResult;
}
