import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repathy/src/util/enum/transference_enum.dart';

part 'transfer_model.freezed.dart';
part 'transfer_model.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class TransferModel with _$TransferModel {
  const factory TransferModel({
    String? id,
    String? patientId,
    String? originalTherapistId,
    String? substituteTherapistId,
    DateTime? sentAt,
    DateTime? deletedAt,
    DateTime? declinedAt,
    DateTime? acceptedAt,
    DateTime? revokedAt,
    String? content,
    @Default(TransferStatus.waiting) TransferStatus status,
  }) = _TransferModel;

  factory TransferModel.fromJson(Map<String, Object?> json) => _$TransferModelFromJson(json);
}