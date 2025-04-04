import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/util/enum/element_size_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class SecodaryButton extends ConsumerWidget {
  const SecodaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ElementSize.standard,
    this.isRounded = true,
  });

  final ElementSize size;
  final bool isRounded;
  final String text;
  final FutureOr<void> Function() onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool formControllerState = ref.watch(formControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
            borderRadius:
                isRounded ? BorderRadius.circular(RepathyStyle.roundedRadius) : BorderRadius.circular(RepathyStyle.standardRadius),
                side: BorderSide(color: RepathyStyle.primaryColor)
          )),
          backgroundColor: WidgetStateProperty.all<Color>(RepathyStyle.backgroundColor),
          fixedSize: WidgetStateProperty.all<Size>(
            switch (size) {
              ElementSize.extraLarge => Size(RepathyStyle.buttonWidthStandard, RepathyStyle.buttonHeightStandard),
              ElementSize.large => Size(RepathyStyle.buttonWidthStandard, RepathyStyle.buttonHeightStandard),
              ElementSize.standard => Size(RepathyStyle.buttonWidthStandard, RepathyStyle.buttonHeightStandard),
              ElementSize.medium => Size(RepathyStyle.buttonWidthMedium, RepathyStyle.buttonHeightMedium),
              ElementSize.small => Size(RepathyStyle.buttonWidthSmall, RepathyStyle.buttonHeightSmall),
              ElementSize.mini => Size(RepathyStyle.buttonWidthMini, RepathyStyle.buttonHeightStandard),
            }
          ),
        ),
        onPressed: () => formControllerState ? onPressed() : null,
        child: formControllerState
            ? Text(
                text,
                style: const TextStyle(
                  color: RepathyStyle.darkTextColor,
                  fontSize: RepathyStyle.standardTextSize,
                  fontWeight: RepathyStyle.standardFontWeight,
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
