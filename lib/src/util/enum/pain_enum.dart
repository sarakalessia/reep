import 'package:freezed_annotation/freezed_annotation.dart';

enum PainEnum {
  @JsonValue("abdominal_pain")
  abdominalPain,
  @JsonValue("arm_pain")
  armPain,
  @JsonValue("knee_pain")
  kneePain,
  @JsonValue("elbow_pain")
  elbowPain,
  @JsonValue("foot_pain")
  footPain,
  @JsonValue("wrist_pain")
  wristPain,
  @JsonValue("hip_pain")
  hipPain,
  @JsonValue("ankle_pain")
  anklePain,
  @JsonValue("leg_pain")
  legPain,
  @JsonValue("hand_pain")
  handPain,
  @JsonValue("shoulder_pain")
  shoulderPain,
  @JsonValue("cervical_pain")
  cervicalPain,
  @JsonValue("facial_pain")
  facialPain,
  @JsonValue("lumbar_pain")
  lumbarPain,
  @JsonValue("sacral_pain")
  sacralPain,
  @JsonValue("anterior_sternal_pain")
  anteriorSternalPain,
  @JsonValue("posterior_chest_pain")
  posteriorChestPain,
  @JsonValue("upper_trapezius_pain")
  upperTrapeziusPain,
  @JsonValue("migraine")
  migraine,
  @JsonValue("headache")
  headache,
  @JsonValue("other")
  other,
}

enum PainLevelEnum {
  @JsonValue("low")
  low,
  @JsonValue("medium")
  medium,
  @JsonValue("high")
  high,
  @JsonValue("unknown")
  unknown,
}