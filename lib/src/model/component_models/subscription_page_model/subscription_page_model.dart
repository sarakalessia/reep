import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repathy/src/model/data_models/plan_model/plan_model.dart';

part 'subscription_page_model.freezed.dart';
part 'subscription_page_model.g.dart';

// THIS IS A "VIEW-LEVEL MODEL" THAT CONVERTS FROM A DATA-LEVEL MODEL PlanModel TO A FRONT-END COMPONENT

@freezed
abstract class PlansPageModel with _$PlansPageModel {
  const factory PlansPageModel({
    required PlanModel subscriptionPlan,
    required bool isCurrent, // The one being shown on the screen now
    required bool isSelected, // The one selected by the user, this is the one that will be purchased
  }) = _PlansPageModel;

  factory PlansPageModel.fromJson(Map<String, Object?> json) => _$PlansPageModelFromJson(json);
}