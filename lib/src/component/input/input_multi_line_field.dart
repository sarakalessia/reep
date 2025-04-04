import 'package:flutter/material.dart';
import 'package:repathy/src/theme/styles.dart';

class InputMultiLineField extends StatelessWidget {
  const InputMultiLineField({
    super.key,
    required this.controller,
    required this.name,
    required this.validator,
    this.leftPadding = 8,
    this.topPadding = 8,
    this.rightPadding = 8,
    this.bottomPadding = 8,
  });

  final TextEditingController controller;
  final String name;
  final String? Function(String? value) validator;
  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        leftPadding,
        topPadding,
        rightPadding,
        bottomPadding,
      ),
      child: TextFormField(
        textInputAction: TextInputAction.done,
        minLines: 3,
        maxLines: 5,
        controller: controller,
        maxLength: 100,
        cursorColor: RepathyStyle.primaryColor,
        decoration: InputDecoration(
          labelText: name,
          labelStyle: const TextStyle(color: RepathyStyle.inputFieldHintTextColor),
          hintText: name,
          hintStyle: const TextStyle(color: RepathyStyle.inputFieldHintTextColor),
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
        ),
        textCapitalization: TextCapitalization.none,
        style: const TextStyle(
          color: RepathyStyle.inputFieldTextColor,
          fontWeight: RepathyStyle.lightFontWeight,
          fontSize: RepathyStyle.smallTextSize,
        ),
        validator: validator,
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
    );
  }
}
