import 'package:freezed_annotation/freezed_annotation.dart';

enum GenderEnum {
  @JsonValue("male")
  male,
  @JsonValue("female")
  female,
  @JsonValue("other")
  other,
}