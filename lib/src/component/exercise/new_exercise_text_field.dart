import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:repathy/src/util/helper/date_formatter/date_formatter.dart';

class ExerciseTextField extends ConsumerStatefulWidget {
  const ExerciseTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    this.isReadOnly = false,
    this.isMultiLine = false,
    this.maxLength,
    this.isDate = false,
    this.isDetailsPage = false,
    this.isNumbersOnly = false,
    this.onChanged,
    this.width,
  });

  final String hintText;
  final TextEditingController controller;
  final bool isMultiLine;
  final int? maxLength;
  final bool isDate;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final double? width;
  final bool isReadOnly;
  final bool isDetailsPage;
  final bool isNumbersOnly;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExerciseTextFieldState();
}

class _ExerciseTextFieldState extends ConsumerState<ExerciseTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: SizedBox(
        height: widget.isMultiLine ? 100 : 45,
        width: widget.width,
        child: TextField(
          readOnly: widget.isReadOnly,
          focusNode: widget.focusNode,
          textInputAction: TextInputAction.done,
          onChanged: widget.onChanged,
          maxLength: widget.maxLength,
          buildCounter:(context, {required currentLength, required isFocused, required maxLength}) => null,
          controller: widget.controller,
          maxLines: widget.isMultiLine ? 3 : 1,
          keyboardType: (widget.isNumbersOnly) ? TextInputType.number : TextInputType.text,
          inputFormatters: (widget.isDate)
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                  DateFormatter(),
                ]
              : [],
          style: TextStyle(
            color: RepathyStyle.darkTextColor,
            fontSize: RepathyStyle.smallTextSize,
          ),
          decoration: InputDecoration(
            labelText: widget.hintText,
            labelStyle: TextStyle(color: widget.isDetailsPage ? RepathyStyle.defaultTextColor : RepathyStyle.inputFieldHintTextColor),
            contentPadding: EdgeInsets.fromLTRB(10, 10, 0, 0),
            filled: true,
            fillColor: RepathyStyle.lightBackgroundColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: RepathyStyle.lightBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: RepathyStyle.lightBorderColor, width: 1.5),
            ),
            suffixIcon: widget.isDate ? Icon(Icons.calendar_today_outlined, color: RepathyStyle.darkTextColor) : null,
          ),
        ),
      ),
    );
  }
}
