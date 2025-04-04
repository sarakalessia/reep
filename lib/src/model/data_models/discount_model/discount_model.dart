import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repathy/src/util/enum/subscription_enum.dart';

part 'discount_model.freezed.dart';
part 'discount_model.g.dart';

@freezed
abstract class DiscountModel with _$DiscountModel {
  const factory DiscountModel({
    String? id,
    double? value, // Only applicable for percentageDiscount
    DateTime? startDate, // Only applicable for freePeriod and trialExtension
    DateTime? endDate, // Only applicable for freePeriod and trialExtension
    int? freeLicenses, // Only applicable for freeLicenses
    @Default(false) isValid, // If false ignore everything else
    @Default(DiscountEnum.none) DiscountEnum discountType,
  }) = _DiscountModel;

  factory DiscountModel.fromJson(Map<String, Object?> json) => _$DiscountModelFromJson(json);
}