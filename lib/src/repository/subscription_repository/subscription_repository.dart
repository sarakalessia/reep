import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/subscription_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:repathy/src/model/data_models/plan_model/plan_model.dart';
import 'package:repathy/src/model/data_models/subscription_model/subscription_model.dart';

part 'subscription_repository.g.dart';

@riverpod
class SubscriptionRepository extends _$SubscriptionRepository {
  @override
  void build() {}

  // CREATE

  // Creates a new "SubscriptionModel" based on a "PlanModel" and links it to the current user
  // Even though we implemented InAppPurchase, we still need to create a subscription in Firestore, and the Plan Collection remains our source of truth
  Future<ResultModel<SubscriptionModel>> createNewSubscription({
    required String userId,
    required PlanModel plan,
    String? studioId,
    // AppleReceiptResponseModel? appleReceipt,
  }) async {
    debugPrint('Repository: createSubscription is called with userId: $userId, plan: $plan');
    final PlanFrequency planFrequency = plan.frequency;
    DateTime endDate = DateTime.now();

    if (planFrequency == PlanFrequency.monthly) endDate = DateTime.now().add(Duration(days: 30));
    if (planFrequency == PlanFrequency.yearly) endDate = DateTime.now().add(Duration(days: 365));

    final subscription = SubscriptionModel(
      planId: plan.id,
      referenceUserId: userId,
      studioId: studioId,
      startDate: DateTime.now(),
      trialEndDate: DateTime.now().add(Duration(days: 7)),
      realEndDate: endDate,
      totalNumberOfLicenses: plan.numberOfLicenses,
      numberOfLicensesUsed: 1,
      frequency: plan.frequency,
      appleProductId: plan.appleProductId,
      googlePlayProductId: plan.googlePlayProductId,
      countryPrices: plan.countryPrices,
      status: SubscriptionStatus.active,
      type: plan.type,
      // appleReceipt: appleReceipt,
    );

    try {
      final subscriptionFromFirestore =
          await ref.read(firestoreInstanceProvider).collection('subscriptions').add(subscription.toJson());
      if (subscriptionFromFirestore.id.isEmpty) {
        return ResultModel(error: 'Repository: createNewSubscription error creating subscription');
      }

      final subscriptionMapFromFirestore = await subscriptionFromFirestore.get();
      if (!subscriptionMapFromFirestore.exists) {
        return ResultModel(error: 'Repository: createNewSubscription error getting subscription');
      }

      final subscriptionModelFromFirestore = SubscriptionModel.fromJson(subscriptionMapFromFirestore.data()!);
      await ref
          .read(firestoreInstanceProvider)
          .collection('subscriptions')
          .doc(subscriptionFromFirestore.id)
          .update({'id': subscriptionFromFirestore.id});

      final String subscriptionType = plan.type == PlanType.patient ? 'patientSubscriptionId' : 'therapistSubscriptionId';

      await ref
          .read(firestoreInstanceProvider)
          .collection('user')
          .doc(userId)
          .set({subscriptionType: subscriptionFromFirestore.id}, SetOptions(merge: true));
      return ResultModel(data: subscriptionModelFromFirestore);
    } catch (e) {
      return ResultModel(error: 'Repository: createNewSubscription error is $e');
    }
  }

  // READ

  // Get the subscription for the current user
  Future<(ResultModel<SubscriptionModel> patient, ResultModel<SubscriptionModel> therapist)> getCurrentUserSubscription(
      UserModel userModel) async {
    debugPrint('Repository: getCurrentUserSubscription is called with userId: ${userModel.id}');
    final String? patientSubscriptionId = userModel.patientSubscriptionId;
    final String? therapistSubscriptionId = userModel.therapistSubscriptionId;
    if (patientSubscriptionId == null && therapistSubscriptionId == null) {
      return (
        ResultModel<SubscriptionModel>(error: 'Repository: getCurrentUserSubscription error: no subscription found for user'),
        ResultModel<SubscriptionModel>(error: 'Repository: getCurrentUserSubscription error: no subscription found for user')
      );
    }
    try {
      final patientSubscriptionSnapshot =
          await ref.read(firestoreInstanceProvider).collection('subscriptions').doc(patientSubscriptionId).get();
      final therapistSubscriptionSnapshot =
          await ref.read(firestoreInstanceProvider).collection('subscriptions').doc(therapistSubscriptionId).get();

      final Map<String, dynamic>? patientDocumentData = patientSubscriptionSnapshot.data();
      final Map<String, dynamic>? therapistDocumentData = therapistSubscriptionSnapshot.data();
      SubscriptionModel? patientSubscription;
      SubscriptionModel? therapistSubscription;
      if (patientDocumentData != null) patientSubscription = SubscriptionModel.fromJson(patientDocumentData);
      if (therapistDocumentData != null) therapistSubscription = SubscriptionModel.fromJson(therapistDocumentData);

      return (ResultModel(data: patientSubscription), ResultModel(data: therapistSubscription));
    } catch (e) {
      return (
        ResultModel<SubscriptionModel>(error: 'Repository: getCurrentUserSubscription error: $e'),
        ResultModel<SubscriptionModel>(error: 'Repository: getCurrentUserSubscription error: $e')
      );
    }
  }

  // Get the subscription history for a user to show in the settings page
  Future<ResultModel<List<SubscriptionModel>>> getSubscriptionHistory(UserModel userModel) async {
    final List<String> subscriptionIds = userModel.subscriptionIdHistory;
    try {
      final querySnapshot =
          await ref.read(firestoreInstanceProvider).collection('subscriptions').where('id', whereIn: subscriptionIds).get();
      final List<SubscriptionModel> subscriptions =
          querySnapshot.docs.map((doc) => SubscriptionModel.fromJson(doc.data())).toList();
      return ResultModel(data: subscriptions);
    } catch (e) {
      return ResultModel(error: 'Repository: error fetching subscription history: $e');
    }
  }

  // This is used when a user receives a license id from the person who bought the license
  // If it's true then they have received a valid license
  // TODO: CHECK IAP TO MAKE SURE THE USER FIRESTORE IS UPDATED WITH APPLE/GOOGLE
  Future<bool> checkForLicenseValidity(String licenseId) async {
    final collection = ref.read(firestoreInstanceProvider).collection('subscriptions');
    try {
      final documentSnapshot = await collection.doc(licenseId).get();
      final documentData = documentSnapshot.data();
      if (documentData == null) return false;
      final SubscriptionModel subscription = SubscriptionModel.fromJson(documentData);
      final bool isExpired = subscription.realEndDate?.isBefore(DateTime.now()) ?? true;
      final bool hasSeatsLeft = subscription.totalNumberOfLicenses! > subscription.numberOfLicensesUsed!;
      if (subscription.status == SubscriptionStatus.active && !isExpired && hasSeatsLeft) return true;
      return false;
    } catch (e) {
      debugPrint('Repository: checkForLicenseValidity error is: $e');
      return false;
    }
  }

  // UPDATE

  // Used for group subscriptions
  Future<bool> linkSubscriptionToUser(String userId, String subscriptionId, PlanType planType) async {
    final String field = planType == PlanType.patient ? 'patientSubscriptionId' : 'therapistSubscriptionId';
    try {
      await ref
          .read(firestoreInstanceProvider)
          .collection('user')
          .doc(userId)
          .set({field: subscriptionId}, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Expires the user's current subscription and adds it to history
  Future<void> expireSubscription(UserModel userModel, PlanType planType) async {
    debugPrint('Repository: expireSubscription is called with userId: ${userModel.id}');
    final String subscriptionId =
        planType == PlanType.patient ? userModel.patientSubscriptionId! : userModel.therapistSubscriptionId!;
    final UserModel updatedUserModel = userModel.copyWith(
      subscriptionIdHistory: [...userModel.subscriptionIdHistory, subscriptionId],
      patientSubscriptionId: planType == PlanType.patient ? null : userModel.patientSubscriptionId,
      therapistSubscriptionId: planType == PlanType.therapist ? null : userModel.therapistSubscriptionId,
    );
    try {
      await ref
          .read(firestoreInstanceProvider)
          .collection('user')
          .doc(userModel.id)
          .set(updatedUserModel.toJson(), SetOptions(merge: true));
      await ref
          .read(firestoreInstanceProvider)
          .collection('subscriptions')
          .doc(subscriptionId)
          .update({'status': SubscriptionStatus.expired.name});
    } catch (e) {
      throw Exception('Repository: error adding subscription to history: $e');
    }
  }

  Future<ResultModel<SubscriptionModel>> updateSubscription(SubscriptionModel subscription) async {
    debugPrint('Repository: updateSubscription is called with subscriptionId: ${subscription.id}');
    try {
      await ref.read(firestoreInstanceProvider).collection('subscriptions').doc(subscription.id).update(subscription.toJson());
      return ResultModel(data: subscription);
    } catch (e) {
      return ResultModel(error: 'Repository: updateSubscription error: $e');
    }
  }
}
