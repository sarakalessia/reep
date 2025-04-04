import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/password_visibility/password_visibility_controller.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InputPasswordField extends ConsumerWidget {
  const InputPasswordField({
    super.key,
    required this.controller,
    required this.validator,
    this.isConfirmation = false,
    this.left = 8,
    this.top = 8,
    this.right = 8,
    this.bottom = 8,
  });

  final TextEditingController controller;
  final String? Function(String? value) validator;
  final bool isConfirmation;
  final double left;
  final double top;
  final double right;
  final double bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool passwordVisibility = ref.watch(passwordVisibilityControllerProvider);
    final bool passwordConfirmationVisibility = ref.watch(passwordConfirmationVisibilityControllerProvider);
    final password = isConfirmation ? AppLocalizations.of(context)!.confirmPassword : AppLocalizations.of(context)!.password;

    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: SizedBox(
        height: RepathyStyle.inputFieldHeight,
        child: TextFormField(
          controller: controller,
          cursorColor: RepathyStyle.primaryColor,
          obscureText: isConfirmation ? !passwordConfirmationVisibility : !passwordVisibility,
          decoration: InputDecoration(
            labelText: '$password*',
            labelStyle: const TextStyle(color: RepathyStyle.inputFieldHintTextColor),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: const BorderSide(
                color: RepathyStyle.inputFieldHintTextColor,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: const BorderSide(
                color: RepathyStyle.inputFieldHintTextColor,
                width: 1.5,
              ),
            ),
            suffixIcon: IconButton(
              icon: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isConfirmation
                        ? passwordConfirmationVisibility == false
                            ? Icons.visibility
                            : Icons.visibility_off
                        : passwordVisibility == false
                            ? Icons.visibility
                            : Icons.visibility_off,
                    color: RepathyStyle.smallIconColor,
                  ),
                ],
              ),
              onPressed: () {
                isConfirmation
                    ? ref.read(passwordConfirmationVisibilityControllerProvider.notifier).changePasswordVisibility()
                    : ref.read(passwordVisibilityControllerProvider.notifier).changePasswordVisibility();
              },
            ),
          ),
          textCapitalization: TextCapitalization.none,
          style: const TextStyle(
            color: RepathyStyle.inputFieldTextColor,
            fontWeight: RepathyStyle.lightFontWeight,
            fontSize: RepathyStyle.smallTextSize,
          ),
          validator: validator,
        ),
      ),
    );
  }
}
