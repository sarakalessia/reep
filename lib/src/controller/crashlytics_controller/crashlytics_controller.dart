import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crashlytics_controller.g.dart';

@riverpod
initializeCrashlytics(Ref ref) {
  FlutterError.onError = (errorDetails) => ref.read(firebaseCrashlyticsInstanceProvider).recordFlutterFatalError(errorDetails);
  PlatformDispatcher.instance.onError = (error, stack) {
    ref.read(firebaseCrashlyticsInstanceProvider).recordError(error, stack, fatal: true);
    return true;
  };
}