import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

// THIS IS USED FOR NOTIFICATIONS
// SPECIFICALLY THE "GENERAL" SECTION WHERE USERS RECEIVE INFORMATION SUCH AS:
// YOUR SUBSCRIPTION ENDS SOON, YOUR COLLEAGUE APPOINTED YOU AS A TEMPORARY THERAPIST, ETC

@freezed
abstract class EventModel with _$EventModel {
  const factory EventModel({
    String? id,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? declinedAt, // Only for transference events
    DateTime? acceptedAt, // Only for transference events
    DateTime? deletedAt,
    String? content,
    String? senderId, // Tt's null when Repathy sends events
    String? mediaId, // Only for video/pdf related events
    String? receiverId,
    String? therapistId, // This is used for filtering purposes
    String? patientId, // This is used for filtering purposes
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, Object?> json) => _$EventModelFromJson(json);
}
