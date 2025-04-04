import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'password_visibility_controller.g.dart';

@riverpod
class PasswordVisibilityController extends _$PasswordVisibilityController {
  @override
  bool build() => false;

  void changePasswordVisibility() {
    state = !state;
    debugPrint(' visibility provider value is $state');
  }
}

@riverpod
class PasswordConfirmationVisibilityController extends _$PasswordConfirmationVisibilityController {
  @override
  bool build() => false;

  void changePasswordVisibility() {
    state = !state;
    debugPrint('debugPrint insde the visibility confirmation provider $state');
  }
}
