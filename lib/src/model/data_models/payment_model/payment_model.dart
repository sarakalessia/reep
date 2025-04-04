import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

@freezed
abstract class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    String? id, // document id just for convenience
    double? value, // how much was paid
    DateTime? paymentDate, 
    String? appleReceiptId, // only for apple payments
    String? googleReceiptId, // only for google payments
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, Object?> json) => _$PaymentModelFromJson(json);
}