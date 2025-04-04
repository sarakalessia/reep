import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/util/enum/element_size_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class PrimaryButton extends ConsumerWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ElementSize.standard,
    this.isRounded = true,
    this.isLightSecondary = false,
    this.isRemove = false,
    this.leftPadding = 0,
    this.topPadding = 8,
    this.rightPadding = 0,
    this.bottomPadding = 8,
  });

  final ElementSize size;
  final bool isRounded;
  final String text;
  final FutureOr<void> Function() onPressed;
  final bool isLightSecondary;
  final bool isRemove;
  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool formControllerState = ref.watch(formControllerProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius: isRounded
                ? BorderRadius.circular(RepathyStyle.roundedRadius)
                : BorderRadius.circular(RepathyStyle.standardRadius),
          )),
          backgroundColor: isRemove
              ? WidgetStateProperty.all<Color>(RepathyStyle.removeColor)
              : isLightSecondary
                  ? WidgetStateProperty.all<Color>(RepathyStyle.lightPrimaryColor)
                  : WidgetStateProperty.all<Color>(RepathyStyle.primaryColor),
          fixedSize: WidgetStateProperty.all<Size>(switch (size) {
            ElementSize.extraLarge => Size(RepathyStyle.buttonWidthStandard, RepathyStyle.buttonHeightStandard),
            ElementSize.large => Size(RepathyStyle.buttonWidthStandard, RepathyStyle.buttonHeightStandard),
            ElementSize.standard => Size(RepathyStyle.buttonWidthStandard, RepathyStyle.buttonHeightStandard),
            ElementSize.medium => Size(RepathyStyle.buttonWidthMedium, RepathyStyle.buttonHeightMedium),
            ElementSize.small => Size(RepathyStyle.buttonWidthSmall, RepathyStyle.buttonHeightSmall),
            ElementSize.mini => Size(RepathyStyle.buttonWidthMini, RepathyStyle.buttonHeightStandard),
          }),
        ),
        onPressed: () => formControllerState ? onPressed() : null,
        child: formControllerState
            ? Text(
                text,
                style: const TextStyle(
                  color: RepathyStyle.backgroundColor,
                  fontSize: RepathyStyle.standardTextSize,
                  fontWeight: RepathyStyle.standardFontWeight,
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
