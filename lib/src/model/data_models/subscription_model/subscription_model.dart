import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repathy/src/model/data_models/country_price_model/country_price_model.dart';
import 'package:repathy/src/model/data_models/discount_model/discount_model.dart';
import 'package:repathy/src/model/data_models/payment_model/payment_model.dart';
import 'package:repathy/src/util/enum/subscription_enum.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

// IN CASE THE USER MOVES TO A NEW SUBSCRIPTION, THE OLD ONE WILL BE EXPIRED
// USERS HAVE A CURRENT SUBSCRIPTION ID + AN ARRAY OF OLD SUBSCRIPTION IDS

@Freezed(makeCollectionsUnmodifiable: false)
abstract class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    String? id,
    String? planId, // Reference to the PlanModel
    String? referenceUserId, // Reference to the user who bought the license
    String? studioId, // Reference to the studio the user belongs to
    String? appleProductId, // Empty for trial plans
    String? googlePlayProductId, // Empty for trial plans
    int? totalNumberOfLicenses, // Number of licenses bought
    int? numberOfLicensesUsed, // Number of licenses used
    DateTime? startDate, // For team subscriptions, it's the date where the first user was added
    DateTime? trialEndDate, // For trial subscriptions, it's the date where the trial ends
    DateTime? realEndDate, // Date where the actual subscription ends, usually trial time + subscription time
    // AppleReceiptResponseModel? appleReceipt, // Receipt from Apple
    @Default(<CountryPriceModel>[]) List<CountryPriceModel> countryPrices,
    @Default(<PaymentModel>[]) List<PaymentModel> payments, // Payments made for the subscription
    @Default(<DiscountModel>[]) List<DiscountModel> discounts, // Discounts applied to the subscription
    @Default(<String>[]) List<String> teamUserIds, // Remaining users besides the reference user
    @Default(PlanFrequency.monthly) PlanFrequency frequency, // weekly means trial
    @Default(PlanType.unknown) PlanType type,
    @Default(SubscriptionStatus.unknown) SubscriptionStatus status,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, Object?> json) => _$SubscriptionModelFromJson(json);
}
