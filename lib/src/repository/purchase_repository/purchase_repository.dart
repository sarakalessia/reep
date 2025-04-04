import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:repathy/src/util/enum/subscription_enum.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:repathy/src/model/data_models/plan_model/plan_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:repathy/src/util/helper/environment_config/environment_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_repository.g.dart';

@riverpod
class PurchaseRepository extends _$PurchaseRepository {
  @override
  void build() {}

  // CREATE

  Future<bool> purchaseProduct({required PlanModel plan}) async {
    debugPrint('Repository: purchaseProduct is called with plan: $plan');

    // Instance of In App Purchase
    final iap = ref.read(inAppPurchaseInstanceProvider);
    debugPrint('Repository: purchaseProduct iap is: $iap');

    // Obtain the definitive ID which will be able to query products
    var chosenProductId = Platform.isIOS ? plan.appleProductId : plan.googlePlayProductId;
    var detailProduct = '';
    //final chosenProductId = '7f3b_92d1.ea458c6d';
    debugPrint('Repository: purchaseProduct chosenProductId is: $chosenProductId');

    if(Platform.isAndroid && chosenProductId != null){
      var result = plan.googlePlayPlanProductId;
      debugPrint("Repository: purchaseProduct chosenPlanAndroidId is $result");
    }

    // Since there's only one product, we'll make a set of a single element
    final Set<String> identifier = {chosenProductId!};
    debugPrint('Repository: purchaseProduct identifier is: $identifier');

    // Query a single product based on the single identifier obtained
    final ProductDetailsResponse productDetailsRes = await iap.queryProductDetails(identifier);
    debugPrint('Repository: purchaseProduct productDetailsRes is: ${productDetailsRes.productDetails}');


    if (Platform.isIOS) {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetailsRes.productDetails.first);
      debugPrint('Repository: purchaseProduct purchaseParam is: $purchaseParam');

      final transactions = await SKPaymentQueueWrapper().transactions();
      debugPrint('Repository: purchaseProduct transactions is: $transactions');
      for (var transaction in transactions) {
        await SKPaymentQueueWrapper().finishTransaction(transaction);
      }

      final bool purchaseResult = await iap.buyNonConsumable(purchaseParam: purchaseParam);
      debugPrint('Repository: purchaseProduct purchaseResult is: $purchaseResult');

      return purchaseResult;
    } else if (Platform.isAndroid){
      ProductDetails? finalDecision = null;

      for(var product in productDetailsRes.productDetails){
        if(product.rawPrice > 30 && plan.type == PlanType.therapist && plan.frequency == PlanFrequency.yearly){
          finalDecision = product;
          break;
        }
        if(product.rawPrice < 30 && plan.type == PlanType.therapist && plan.frequency == PlanFrequency.monthly){
          finalDecision = product;
          break;
        }
      }

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: finalDecision!);
      debugPrint('Repository: purchaseProduct purchaseParam android is: $purchaseParam');

      final bool purchaseResult = await iap.buyNonConsumable(purchaseParam: purchaseParam);
      debugPrint('Repository: purchaseProduct purchaseResult android  is: $purchaseResult');

      return purchaseResult;
    }

    return false;
  }

  // READ

  // VERIFY APPLE RECEIPT BY CALLING A CLOUD FUNCTION, THIS HAS TO BE DONE SERVER TO SERVER
  Future<ResultModel<bool>> verifyAppleReceipt(String receiptData, PlanModel plan) async {
    debugPrint("Repository: verifyAppleReceipt is called with receiptData: $receiptData and plan id: ${plan.id}");

    final http.Response response;
    final dynamic decodedResponse;
    final String body;
    final String endpointUrl = ref.read(environmentConfigProvider).requireValue['VERIFY_APPLE_RECEIPT_URL'] ?? '';
    final Uri uri = Uri.parse(endpointUrl);

    final String? appCheckToken = await ref.read(firebaseAppCheckInstanceProvider).getToken();

    if (appCheckToken == null) {
      debugPrint("Repository: verifyAppleReceipt - App Check token is null");
      return ResultModel(error: 'App Check token is missing');
    }

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "X-Firebase-AppCheck": appCheckToken,
    };

    try {
      body = json.encode({
        'receiptData': receiptData,
        'plan': plan.toJson(),
      });

      response = await http.post(uri, headers: headers, body: body);

      decodedResponse = jsonDecode(response.body);

      debugPrint("Repository: verifyAppleReceipt decodedResponse is $decodedResponse");

      if (response.statusCode == 200) {
        if (decodedResponse['success'] == true) {
          // final receiptModel = AppleReceiptResponseModel.fromJson(decodedResponse as Map<String, dynamic>);
          debugPrint("Repository: verifyAppleReceipt receiptModel is ${decodedResponse['success']}");
          return ResultModel(data: true);
        } else {
          return ResultModel(
              error: decodedResponse['error'] ?? 'Apple Receipt Verification Failed (Cloud Function reported failure)');
        }
      } else {
        debugPrint("Repository: verifyAppleReceipt error: ${response.statusCode} ${response.reasonPhrase}");
        return ResultModel(error: 'HTTP Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint("Repository: verifyAppleReceipt error is: $e");
      return ResultModel(error: 'Exception during receipt verification: $e');
    }
  }

  Future<ResultModel<bool>> verifyGooglePlayReceipt(PurchaseDetails purchaseDetails, PlanModel plan) async {
    debugPrint("Repository: verifyGoogleReceipt is called with purchaseDetails $purchaseDetails and plan id: ${plan.id}");

    final http.Response response;
    final dynamic decodedResponse;
    final String body;
    final String endpointUrl = ref.read(environmentConfigProvider).requireValue['VERIFY_ANDROID_RECEIPT_URL'] ?? '';
    final Uri uri = Uri.parse(endpointUrl);
    const String packageName = 'com.hexagon.repathy';
    final String? purchaseToken = purchaseDetails.purchaseID;
    final String productId = purchaseDetails.productID;

    if (purchaseToken == null) return ResultModel(error: 'Android Purchase Token is missing from PurchaseDetails');

    final String? appCheckToken = await ref.read(firebaseAppCheckInstanceProvider).getToken();

    if (appCheckToken == null) {
      debugPrint("Repository: verifyGoogleReceipt - App Check token is null");
      return ResultModel(error: 'App Check token is missing');
    }

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "X-Firebase-AppCheck": appCheckToken,
    };

    try {
      body = json.encode({
        'purchaseToken': purchaseToken,
        'productId': productId,
        'packageName': packageName,
      });

      response = await http.post(uri, headers: headers, body: body);

      decodedResponse = jsonDecode(response.body);

      debugPrint("Repository: verifyGoogleReceipt decodedResponse is $decodedResponse");

      if (response.statusCode == 200) {
        if (decodedResponse['success'] == true) {
          debugPrint("Repository: verifyGoogleReceipt receiptModel is ${decodedResponse['success']}");
          return ResultModel(data: true);
        } else {
          return ResultModel(
              error: decodedResponse['error'] ?? 'Google Receipt Verification Failed (Cloud Function reported failure)');
        }
      } else {
        debugPrint("Repository: verifyGoogleReceipt error: ${response.statusCode} ${response.reasonPhrase}");
        return ResultModel(error: 'HTTP Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint("Repository: verifyGoogleReceipt error is: $e");
      return ResultModel(error: 'Exception during receipt verification: $e');
    }
  }
}
