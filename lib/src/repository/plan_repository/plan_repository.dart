import 'package:flutter/material.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:repathy/src/model/data_models/plan_model/plan_model.dart';

part 'plan_repository.g.dart';

@riverpod
class PlanRepository extends _$PlanRepository {
  @override
  void build() {}

  // READ

  // Query a list of plans based on their version
  Future<ResultModel<List<PlanModel>>> getPlans(String version) async {
    debugPrint('Repository: getSubscriptionPlans is called with version: $version');
    try {
      final path = 'plans';
      final documentSnapshot = await ref.read(firestoreInstanceProvider).collection(path).doc(version).get();
      final documentData = documentSnapshot.data();

      if (documentData == null) return ResultModel(error: 'There are no entries in the database for the version: $version');

      debugPrint('Repository: getSubscriptionPlans documentData is: $documentData');

      final planModels = documentData.entries.map((entry) => PlanModel.fromJson(entry.value as Map<String, dynamic>)).toList();

      debugPrint('Repository: getSubscriptionPlans is about to return plans: $planModels');
      return ResultModel(data: planModels);
    } catch (e) {
      debugPrint('Repository: getSubscriptionPlans error fetching subscription plans: $e');
      return ResultModel(error: 'Repository: error fetching subscriptions: $e');
    }
  }
}
