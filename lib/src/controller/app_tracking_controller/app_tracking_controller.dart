import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/util/helper/snackbar/snackbar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_tracking_controller.g.dart';

@riverpod
FutureOr<void> initAppTracking(Ref ref) async {
  debugPrint('Controller: initAppTracking is called');
  final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;

  debugPrint('Controller: initAppTracking status is $status');

  if (status == TrackingStatus.notDetermined) {
    debugPrint('Controller: initAppTracking status is notDetermined');

    final BuildContext? context = ref.read(navigatorKeyProvider).currentContext;

    if (context == null || context.mounted == false) {
      debugPrint('Controller: initAppTracking context is null');
      return;
    }

    final TrackingStatus status = await AppTrackingTransparency.requestTrackingAuthorization();

    debugPrint('Controller: initAppTracking status after request is $status');
  }

  final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
  debugPrint("Controller: AppTracking UUID: $uuid");
}