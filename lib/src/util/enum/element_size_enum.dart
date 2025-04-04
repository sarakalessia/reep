import 'package:freezed_annotation/freezed_annotation.dart';

// After studying the Figma file for this project I concluded there are at most 6 variations to all widgets
// For example, the app's main button can be found in 4 different widths: 353, 333, 210, 126
// Another example: icons can be found in 48, 33, 24 and 20
// Last example: texts are found in 14, 16, 28, 25, 30 and 40 *

// Within widgets we can use a switch case to map the enum to the actual value
// Simply add a required this.elementSize to the widget's constructor, with a default falue as a fallback

enum ElementSize {
  @JsonValue("extraLarge")
  extraLarge,
  @JsonValue("large")
  large,
  @JsonValue("standard")
  standard,
  @JsonValue("medium")
  medium,
  @JsonValue("small")
  small,
  @JsonValue("mini")
  mini,
}