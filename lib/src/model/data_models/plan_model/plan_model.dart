import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repathy/src/model/data_models/country_price_model/country_price_model.dart';
import 'package:repathy/src/util/enum/subscription_enum.dart';

part 'plan_model.freezed.dart';
part 'plan_model.g.dart';

@freezed
abstract class PlanModel with _$PlanModel {
  const factory PlanModel({
    required String id,
    required String name,
    required int numberOfLicenses,
    String? appleProductId, // Empty for trial plans
    String? googlePlayProductId, // Empty for trial plans
    String? googlePlayPlanProductId, // Empty for trial plans
    @Default(<CountryPriceModel>[]) List<CountryPriceModel> countryPrices,
    @Default(PlanFrequency.monthly) PlanFrequency frequency,
    @Default(PlanType.unknown) PlanType type,
  }) = _PlanModel;

  factory PlanModel.fromJson(Map<String, Object?> json) => _$PlanModelFromJson(json);
}