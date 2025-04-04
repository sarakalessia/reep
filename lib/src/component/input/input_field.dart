import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/util/helper/date_formatter/date_formatter.dart';
import 'package:repathy/src/theme/styles.dart';

class InputFormField extends ConsumerStatefulWidget {
  const InputFormField({
    super.key,
    required this.controller,
    required this.name,
    required this.validator,
    this.suffixIcon,
    this.isDate = false,
    this.focusNode,
    this.left = 8,
    this.top = 8,
    this.right = 8,
    this.bottom = 8,
    this.isReadOnly = false,
    this.shouldCapitalizeSentence = true,
  });

  final TextEditingController controller;
  final String name;
  final String? Function(String? value) validator;
  final Widget? suffixIcon;
  final bool isDate;
  final FocusNode? focusNode;
  final double left;
  final double top;
  final double right;
  final double bottom;
  final bool isReadOnly;
  final bool shouldCapitalizeSentence;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InputFormFieldState();
}

class _InputFormFieldState extends ConsumerState<InputFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.left, widget.top, widget.right, widget.bottom),
      child: SizedBox(
        height: RepathyStyle.inputFieldHeight,
        child: TextFormField(
          readOnly: widget.isReadOnly,
          focusNode: widget.focusNode,
          inputFormatters: (widget.isDate)
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                  DateFormatter(),
                ]
              : [],
          controller: widget.controller,
          cursorColor: RepathyStyle.primaryColor,
          decoration: InputDecoration(
            suffixIcon: widget.suffixIcon,
            labelText: widget.name,
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
          ),
          textCapitalization: widget.shouldCapitalizeSentence ? TextCapitalization.sentences : TextCapitalization.none,
          style:  TextStyle(
            color: widget.isReadOnly ? RepathyStyle.smallIconColor : RepathyStyle.inputFieldTextColor,
            fontWeight: RepathyStyle.lightFontWeight,
            fontSize: RepathyStyle.smallTextSize,
          ),
          validator: widget.validator,
        ),
      ),
    );
  }
}
