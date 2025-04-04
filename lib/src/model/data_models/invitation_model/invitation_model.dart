import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repathy/src/util/enum/invitation_enum.dart';

part 'invitation_model.freezed.dart';
part 'invitation_model.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class InvitationModel with _$InvitationModel {
  const factory InvitationModel({
    String? id,
    String? senderId,
    String? receiverId,
    DateTime? sentAt,
    DateTime? readAt, // CURRENTLY NOT USED
    DateTime? deletedAt,
    DateTime? declinedAt,
    DateTime? acceptedAt,
    String? content,
    @Default(InvitationStatus.waiting) InvitationStatus status,
  }) = _InvitationModel;

  factory InvitationModel.fromJson(Map<String, Object?> json) => _$InvitationModelFromJson(json);
}