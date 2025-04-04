import 'package:freezed_annotation/freezed_annotation.dart';

enum PlanFrequency {
  @JsonValue("monthly")
  monthly,
  @JsonValue("yearly")
  yearly,
}

enum PlanType {
  @JsonValue("patient")
  patient,
  @JsonValue("therapist")
  therapist,
  @JsonValue("unknown")
  unknown,
}

enum SubscriptionVersion {
  @JsonValue("v1")
  v1,
  @JsonValue("v2")
  v2,
  @JsonValue("v3")
  v3,
}

enum SubscriptionStatus {
  @JsonValue("active")
  active,
  @JsonValue("suspended")
  suspended,
  @JsonValue("expired")
  expired,
  @JsonValue("unknown")
  unknown,
}

enum DiscountEnum {
  @JsonValue("trial")
  trial,
  @JsonValue("percentageDiscount")
  percentageDiscount,
  @JsonValue("freeLicenses")
  freeLicenses,
  @JsonValue("none")
  none,
}
