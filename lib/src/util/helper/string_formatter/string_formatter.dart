// This class is used outside of the widget tree, that's why it's not a provider
// TODO: Make it a provider and use a container to make it work

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'string_formatter.g.dart';

@riverpod
class StringFormatter extends _$StringFormatter {
  @override
  void build() {}

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

    static int? stringToNum(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
