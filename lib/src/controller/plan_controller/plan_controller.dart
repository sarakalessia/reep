import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/component_models/subscription_page_model/subscription_page_model.dart';
import 'package:repathy/src/model/data_models/plan_model/plan_model.dart';
import 'package:repathy/src/repository/plan_repository/plan_repository.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:repathy/src/util/enum/subscription_enum.dart';

part 'plan_controller.g.dart';

// THIS KEEPS TRACK OF THE PLANS THAT WILL BE SHOWN FOR SALE
// IT ESSENTIALLY CONVERTS THE PLAN MODELS INTO A "VIEW MODEL"
// THIS FEEDS THE "SYNC PLAN PAGE CONTROLLER" PROVIDER
// THIS IS USED IN THE SUBSCRIPTION PAGE TO SHOW THE SUBSCRIPTION BOX WIDGET

@riverpod
FutureOr<List<PlansPageModel>> asyncPlanPageController(Ref ref) async {
  final result = await ref.read(planRepositoryProvider.notifier).getPlans('v1');

  if (result.error != null) return <PlansPageModel>[];

  final List<PlanModel>? plansList = result.data;

  if (plansList == null || plansList.isEmpty) return <PlansPageModel>[];

  final userModel = ref.read(userControllerProvider);
  final userRole = userModel?.role;
  if (userRole == null) return <PlansPageModel>[];

  debugPrint('Controller: asyncPlanPageController userRole is $userRole');

  if (userRole == RoleEnum.patient) {
    plansList.removeWhere((sortedPlan) => sortedPlan.type == PlanType.therapist);
    debugPrint('Controller: asyncPlanPageController plansList for patients is ${plansList.length}');
  }

  if (userRole == RoleEnum.therapist) {
    plansList.removeWhere((sortedPlan) => sortedPlan.type == PlanType.patient);
    debugPrint('Controller: asyncPlanPageController plansList for therapists is ${plansList.length}');
  }

  final List<PlansPageModel> plans = [
    for (final plan in plansList)
      PlansPageModel(
        subscriptionPlan: plan,
        isSelected: false,
        isCurrent: false,
      ),
  ];

  debugPrint('Controller: asyncPlanPageController plansList is ${plans.length}');

  ref.read(syncPlanPageControllerProvider.notifier).updateState(plans);

  return plans;
}

// THIS IS HOW WE MANAGE THE STATE OF PLANS IN A SYNCHRONOUS WAY

@riverpod
class SyncPlanPageController extends _$SyncPlanPageController {
  @override
  List<PlansPageModel> build() => <PlansPageModel>[];

  void updateState(List<PlansPageModel> newPlans) => state = newPlans;
}

// THIS KEEPS TRACK OF THE CURRENT PLAN FREQUENCY (MONTHLY OR YEARLY)
// IT'S USED TO FILTER THE PLANS IN THE "SubscriptionTag" WIDGET
// IT'S ALSO USED TO FILTER THE PLANS IN THE "FilteredPlansPageController" PROVIDER

@riverpod
class CurrentPlanFrequency extends _$CurrentPlanFrequency {
  @override
  PlanFrequency build() => PlanFrequency.monthly;

  updateFilter(String title) {
    final frequency = title == 'mensile' ? PlanFrequency.monthly : PlanFrequency.yearly;
    return state = frequency;
  }
}

// THIS IS HOW WE SHOW ONLY MONTHLY OR ANNUAL PLANS
// THIS PROVIDER IS USED TO FILTER THE PLANS BASED ON THE FREQUENCY
// THIS IS USED IN THE "SUBSCRIPTION BOX" AND "SELECTION BUTTON" WIDGETS

@riverpod
class FilteredPlansPageController extends _$FilteredPlansPageController {
  @override
  List<PlansPageModel> build() {
    final List<PlansPageModel> plans = ref.watch(syncPlanPageControllerProvider);
    final PlanFrequency frequency = ref.watch(currentPlanFrequencyProvider);
    final filteredPlans = plans.where((plan) => plan.subscriptionPlan.frequency == frequency).toList();
    return filteredPlans;
  }

  // THIS DECIDES WHICH PLAN IS CURRENTLY BEING SHOWN ON THE SCREEN
  void setCurrentPlan() {
    final int index = ref.read(currentPlanIndexProvider);
    state = state.asMap().entries.map((entry) {
      final int idx = entry.key;
      final PlansPageModel model = entry.value;
      return model.copyWith(isCurrent: idx == index);
    }).toList();
  }

  // THIS GETS THE CURRENT PLAN AND CHANGES ITS STATUS TO SELECTED
  void changeCurrentPlanToIsSelected() {
    final int index = ref.read(currentPlanIndexProvider);
    state = state.asMap().entries.map((entry) {
      final int idx = entry.key;
      final PlansPageModel model = entry.value;
      return model.copyWith(isSelected: idx == index);
    }).toList();
  }
}

// THIS TRACKS THE CURRENT PLAN SHOWN ON THE SCREEN BASED ON AN INDEX
// IN V1 WE HAVE 0-1 FOR MONTHLY PLANS AND 2-3 FOR YEARLY ONES

@riverpod
class CurrentPlanIndex extends _$CurrentPlanIndex {
  @override
  int build() => 0;

  newIndex(int index) => state = index;
}

// THIS PROVIDER MIXES THE "CURRENT PLAN INDEX" AND THE "FILTERED PLANS PAGE" PROVIDERS

@riverpod
PlansPageModel? currentPlanPageModel(Ref ref) {
  final filteredPlansPageController = ref.watch(filteredPlansPageControllerProvider);
  final currentIndexController = ref.watch(currentPlanIndexProvider);

  if (currentIndexController < 0 || currentIndexController >= filteredPlansPageController.length) {
    return null;
  }

  debugPrint('currentPlanPageModel is ${filteredPlansPageController[currentIndexController]}');
  return filteredPlansPageController[currentIndexController];
}

// THIS IS USED TO CONTROL IF THE "CONTINUA" BUTTON SHOULD BE ENABLED OR NOT


@riverpod
class CheckIfAnyPlanIsSelected extends _$CheckIfAnyPlanIsSelected {
  @override
  bool build() {
    final filteredPlansPageModel = ref.watch(filteredPlansPageControllerProvider);
    final selectedPlan = filteredPlansPageModel.where((model) => model.isSelected).toList();
    debugPrint('CheckIfAnyPlanIsSelected selected subscription is $selectedPlan');
    if (selectedPlan.isEmpty) return false;
    return true;
  }
}
