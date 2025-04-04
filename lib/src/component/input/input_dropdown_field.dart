import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/theme/styles.dart';

class InputDropdownField extends ConsumerStatefulWidget {
  const InputDropdownField({
    super.key,
    required this.items,
    required this.name,
    required this.validator,
    required this.onChanged,
    this.initialValue,
  });

  final String? Function(String? value) validator;
  final Function(String? value) onChanged;
  final List<String> items;
  final String name;
  final String? initialValue;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InputDropdownFieldState();
}

class _InputDropdownFieldState extends ConsumerState<InputDropdownField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: RepathyStyle.inputFieldHeight,
        child: DropdownButtonFormField(
          value: widget.initialValue,
          decoration: InputDecoration(
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
          style: const TextStyle(
            color: RepathyStyle.inputFieldTextColor,
            fontWeight: RepathyStyle.lightFontWeight,
            fontSize: RepathyStyle.smallTextSize,
          ),
          dropdownColor: RepathyStyle.backgroundColor,
          items: widget.items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item.substring(0, 1).toUpperCase() + item.substring(1),
                style: const TextStyle(
                  color: RepathyStyle.inputFieldTextColor,
                  fontWeight: RepathyStyle.lightFontWeight,
                  fontSize: RepathyStyle.smallTextSize,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? value) async => await widget.onChanged(value),
          validator: (String? value) => widget.validator(value),
        ),
      ),
    );
  }
}
