import 'package:freezed_annotation/freezed_annotation.dart';

enum RoleEnum {
  @JsonValue("therapist")
  therapist,
  @JsonValue("patient")
  patient,
  @JsonValue("unknown")
  unknown,
}

extension RoleEnumExtension on RoleEnum {
  String toJson() {
    switch (this) {
      case RoleEnum.therapist:
        return "therapist";
      case RoleEnum.patient:
        return "patient";
      case RoleEnum.unknown:
        return "unknown";
    }
  }

  static RoleEnum fromJson(String json) {
    switch (json) {
      case "therapist":
        return RoleEnum.therapist;
      case "patient":
        return RoleEnum.patient;
      case "unknown":
      default:
        return RoleEnum.unknown;
    }
  }
}
