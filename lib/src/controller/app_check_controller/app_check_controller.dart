import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_check_controller.g.dart';

@riverpod
FutureOr<void> initializeAppCheck(Ref ref) async {
  debugPrint('Controller: initializeAppCheck is called');
  final AndroidProvider androidProvider;
  final AppleProvider appleProvider;

  if (kDebugMode) {
    debugPrint('Controller: AppleProvider.debug && AndroidProvider.debug');
    androidProvider = AndroidProvider.debug;
    appleProvider = AppleProvider.debug;
  } else {
    debugPrint('Controller: AppleProvider.appAttest && AndroidProvider.playIntegrity');
    androidProvider = AndroidProvider.playIntegrity;
    appleProvider = AppleProvider.appAttestWithDeviceCheckFallback;
  }

  await ref.read(firebaseAppCheckInstanceProvider).activate(androidProvider: androidProvider, appleProvider: appleProvider);
  await ref.read(firebaseAppCheckInstanceProvider).setTokenAutoRefreshEnabled(true);

  debugPrint('Controller: initializeAppCheck is done');

  return;
}