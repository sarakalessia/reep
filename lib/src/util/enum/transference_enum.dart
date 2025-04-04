import 'package:freezed_annotation/freezed_annotation.dart';

enum TransferStatus {
  @JsonValue("accepted")
  accepted,
  @JsonValue("waiting")
  waiting,
  @JsonValue("rejected")
  rejected,
  @JsonValue("revoked")
  revoked,
  @JsonValue("unknown")
  unknown,
}
