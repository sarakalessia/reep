import 'package:freezed_annotation/freezed_annotation.dart';

enum InvitationStatus {
  @JsonValue("accepted")
  accepted,
  @JsonValue("waiting")
  waiting,
  @JsonValue("rejected")
  rejected,
  @JsonValue("unknown")
  unknown,
}
