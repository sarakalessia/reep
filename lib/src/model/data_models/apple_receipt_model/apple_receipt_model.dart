// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'apple_receipt_model.freezed.dart';
part 'apple_receipt_model.g.dart';

@freezed
abstract class AppleReceiptResponseModel with _$AppleReceiptResponseModel {
  const factory AppleReceiptResponseModel({
    required bool success,
    required String message,
    AppleResponseModel? appleResponse,
  }) = _AppleReceiptResponseModel;

  factory AppleReceiptResponseModel.fromJson(Map<String, dynamic> json) => _$AppleReceiptResponseModelFromJson(json);
}

@freezed
abstract class AppleResponseModel with _$AppleResponseModel {
  const factory AppleResponseModel({
    String? environment,
    ReceiptModel? receipt,
    @JsonKey(name: 'latest_receipt_info') @Default(<LatestReceiptInfoModel>[]) List<LatestReceiptInfoModel> latestReceiptInfo,
    @JsonKey(name: 'latest_receipt') String? latestReceipt,
    @JsonKey(name: 'pending_renewal_info') @Default(<PendingRenewalInfoModel>[]) List<PendingRenewalInfoModel> pendingRenewalInfo,
    String? status,
  }) = _AppleResponseModel;

  factory AppleResponseModel.fromJson(Map<String, dynamic> json) => _$AppleResponseModelFromJson(json);
}

@freezed
abstract class ReceiptModel with _$ReceiptModel {
  const factory ReceiptModel({
    @JsonKey(name: 'receipt_type') String? receiptType,
    @JsonKey(name: 'adam_id') String? adamId,
    @JsonKey(name: 'app_item_id') int? appItemId,
    @JsonKey(name: 'bundle_id') int? bundleId,
    @JsonKey(name: 'application_version') String? applicationVersion,
    @JsonKey(name: 'download_id') String? downloadId,
    @JsonKey(name: 'version_external_identifier') String? versionExternalIdentifier,
    @JsonKey(name: 'receipt_creation_date') DateTime? receiptCreationDate,
    @JsonKey(name: 'receipt_creation_date_ms') String? receiptCreationDateMs,
    @JsonKey(name: 'receipt_creation_date_pst') DateTime? receiptCreationDatePst,
    @JsonKey(name: 'request_date') DateTime? requestDate,
    @JsonKey(name: 'request_date_ms') String? requestDateMs,
    @JsonKey(name: 'request_date_pst') DateTime? requestDatePst,
    @JsonKey(name: 'original_purchase_date') DateTime? originalPurchaseDate,
    @JsonKey(name: 'original_purchase_date_ms') String? originalPurchaseDateMs,
    @JsonKey(name: 'original_purchase_date_pst') DateTime? originalPurchaseDatePst,
    @JsonKey(name: 'original_application_version') String? originalApplicationVersion,
    @JsonKey(name: 'in_app') @Default(<InAppPurchaseModel>[]) List<InAppPurchaseModel> inApp,
  }) = _ReceiptModel;

  factory ReceiptModel.fromJson(Map<String, dynamic> json) => _$ReceiptModelFromJson(json);
}

@freezed
abstract class InAppPurchaseModel with _$InAppPurchaseModel {
  const factory InAppPurchaseModel({
    String? quantity,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'transaction_id') String? transactionId,
    @JsonKey(name: 'original_transaction_id') String? originalTransactionId,
    @JsonKey(name: 'purchase_date') DateTime? purchaseDate,
    @JsonKey(name: 'purchase_date_ms') String? purchaseDateMs,
    @JsonKey(name: 'purchase_date_pst') DateTime? purchaseDatePst,
    @JsonKey(name: 'original_purchase_date') DateTime? originalPurchaseDate,
    @JsonKey(name: 'original_purchase_date_ms') String? originalPurchaseDateMs,
    @JsonKey(name: 'original_purchase_date_pst') DateTime? originalPurchaseDatePst,
    @JsonKey(name: 'expires_date') DateTime? expiresDate,
    @JsonKey(name: 'expires_date_ms') String? expiresDateMs,
    @JsonKey(name: 'expires_date_pst') DateTime? expiresDatePst,
    @JsonKey(name: 'web_order_line_item_id') String? webOrderLineItemId,
    @JsonKey(name: 'is_trial_period') bool? isTrialPeriod,
    @JsonKey(name: 'is_in_intro_offer_period') bool? isInIntroOfferPeriod,
    @JsonKey(name: 'in_app_ownership_type') String? inAppOwnershipType,
    @JsonKey(name: 'subscription_group_identifier') String? subscriptionGroupIdentifier,
  }) = _InAppPurchaseModel;

  factory InAppPurchaseModel.fromJson(Map<String, dynamic> json) => _$InAppPurchaseModelFromJson(json);
}

@freezed
abstract class LatestReceiptInfoModel with _$LatestReceiptInfoModel {
  const factory LatestReceiptInfoModel({
    String? quantity,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'transaction_id') String? transactionId,
    @JsonKey(name: 'original_transaction_id') String? originalTransactionId,
    @JsonKey(name: 'purchase_date') String? purchaseDate,
    @JsonKey(name: 'purchase_date_ms') String? purchaseDateMs,
    @JsonKey(name: 'purchase_date_pst') String? purchaseDatePst,
    @JsonKey(name: 'original_purchase_date') String? originalPurchaseDate,
    @JsonKey(name: 'original_purchase_date_ms') String? originalPurchaseDateMs,
    @JsonKey(name: 'original_purchase_date_pst') String? originalPurchaseDatePst,
    @JsonKey(name: 'expires_date') String? expiresDate,
    @JsonKey(name: 'expires_date_ms') String? expiresDateMs,
    @JsonKey(name: 'expires_date_pst') String? expiresDatePst,
    @JsonKey(name: 'web_order_line_item_id') String? webOrderLineItemId,
    @JsonKey(name: 'is_trial_period') bool? isTrialPeriod,
    @JsonKey(name: 'is_in_intro_offer_period') bool? isInIntroOfferPeriod,
    @JsonKey(name: 'in_app_ownership_type') String? inAppOwnershipType,
    @JsonKey(name: 'subscription_group_identifier') String? subscriptionGroupIdentifier,
  }) = _LatestReceiptInfoModel;

  factory LatestReceiptInfoModel.fromJson(Map<String, dynamic> json) => _$LatestReceiptInfoModelFromJson(json);
}

@freezed
abstract class PendingRenewalInfoModel with _$PendingRenewalInfoModel {
  const factory PendingRenewalInfoModel({
    @JsonKey(name: 'auto_renew_product_id') String? autoRenewProductId,
    @JsonKey(name: 'product_id') String? productId,
    @JsonKey(name: 'original_transaction_id') String? originalTransactionId,
    @JsonKey(name: 'auto_renew_status') int? autoRenewStatus,
  }) = _PendingRenewalInfoModel;

  factory PendingRenewalInfoModel.fromJson(Map<String, dynamic> json) => _$PendingRenewalInfoModelFromJson(json);
}


