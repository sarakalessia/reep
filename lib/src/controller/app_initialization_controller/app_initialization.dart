import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/app_check_controller/app_check_controller.dart';
import 'package:repathy/src/controller/app_tracking_controller/app_tracking_controller.dart';
import 'package:repathy/src/controller/crashlytics_controller/crashlytics_controller.dart';
import 'package:repathy/src/controller/locale_controller/locale_controller.dart';
import 'package:repathy/src/controller/notification_controller/notification_controller.dart';
import 'package:repathy/src/util/helper/environment_config/environment_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_initialization.g.dart';

@Riverpod(keepAlive: true)
Future<void> appInitialization(Ref ref) async {
  ref.onDispose(() {
    ref.invalidate(localeControllerProvider);
    ref.invalidate(environmentConfigProvider);
  });

  // Use .read for providers we need to initialize but not cache its result
  // Use .watch to cache results

  // Initialize Crashlytics before anything else to catch any errors
  ref.read(initializeCrashlyticsProvider);

  // Initialize Firebase App Check before any other Firebase services
  await ref.read(initializeAppCheckProvider.future);

  // Initialize all Keys from either .env or the server
  await ref.watch(environmentConfigProvider.future);

  // Get Tracking permission from the user
  await ref.read(initAppTrackingProvider.future);

  // All asynchronous app initialization code should belong here:
  await Future.wait([
    ref.read(initNotificationControllerProvider.future),
    ref.read(localeControllerProvider.notifier).getLocale(),
  ]);

  debugPrint('Controller: appInitialization initialized all providers');

}
