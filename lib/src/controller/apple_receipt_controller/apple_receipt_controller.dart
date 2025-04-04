import 'package:flutter/material.dart';
import 'package:repathy/src/model/data_models/apple_receipt_model/apple_receipt_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'apple_receipt_controller.g.dart';

// TODO: EITHER IMPLEMENT THIS OR DO ALL THE HEAVY WORK ON THE BACKEND
@Riverpod(keepAlive: true)
class AppleReceiptController extends _$AppleReceiptController {
  @override
  AppleReceiptResponseModel? build() => null;

  void setAppleReceipt(AppleReceiptResponseModel appleReceipt) {
    debugPrint('Controller: setAppleReceipt is called with appleReceipt: $appleReceipt');
    state = appleReceipt;
  }
}
