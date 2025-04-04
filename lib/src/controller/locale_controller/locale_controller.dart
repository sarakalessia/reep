import 'package:flutter/material.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_controller.g.dart';

@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Locale build() {
    debugPrint('Controller: locale provider build method is called');
    return Locale('en');
  }

  Future<void> setLocale(Locale newLocale) async {
    await ref.read(sharedPreferencesProvider).setString('locale', newLocale.languageCode);
    debugPrint('Controller: locale value after setting it is ${newLocale.languageCode}');
    state = newLocale;
  }

  Future<void> getLocale() async {
    String? locale = await ref.read(sharedPreferencesProvider).getString('locale');
    debugPrint('Controller: locale value after getting it from local is $locale');
    if (locale != null) {
      debugPrint('Controller: locale value after getting it from local is $locale');
      state = Locale(locale);
      debugPrint('Controller: locale value after setting it is ${state.languageCode}');
    }
  }
}

