import 'package:flutter/services.dart';

class DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final buffer = StringBuffer();
    int selectionIndex = newValue.selection.end;

    final digitsOnly = text.replaceAll('/', '');

    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
        if (i < selectionIndex) {
          selectionIndex++;
        }
      }
      buffer.write(digitsOnly[i]);
    }

    final formattedText = buffer.toString();

    if (selectionIndex < 0) {
      selectionIndex = 0;
    }

    if (selectionIndex > formattedText.length) {
      selectionIndex = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
