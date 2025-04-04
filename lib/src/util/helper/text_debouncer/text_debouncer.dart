import 'dart:async';
import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'text_debouncer.g.dart';

@riverpod
class TextDebouncer extends _$TextDebouncer {
  @override
  Timer? build() => null;

  void run(VoidCallback action, {Duration delay = const Duration(milliseconds: 200)}) {
    state?.cancel();
    state = Timer(delay, action);
  }
}
