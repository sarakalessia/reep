import 'package:flutter/material.dart';
import 'package:repathy/src/theme/styles.dart';

class RepathyTheme {
  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      fontFamily: RepathyStyle.primaryFont,
      colorSchemeSeed: RepathyStyle.primaryColor,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        circularTrackColor: RepathyStyle.primaryColor,
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(RepathyStyle.primaryColor),
      ));
}
