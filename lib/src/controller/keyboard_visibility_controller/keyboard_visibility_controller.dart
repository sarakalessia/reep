import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'keyboard_visibility_controller.g.dart';

@riverpod
class KeyboardVisibilityController extends _$KeyboardVisibilityController {
  @override
  bool build() => false;

  void setKeyboardVisibilityToFalse() => state = false;
  void setKeyboardVisibilityToTrue() => state = true;
}