import 'package:flutter/material.dart';
import 'package:repathy/src/controller/subscription_controller/subscription_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/subscription_model/subscription_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'route_controller.g.dart';

@riverpod
class RouteController extends _$RouteController {
  @override
  Future<String?> build({String? desiredRoute, String? backupRoute}) async {
    try {
      // CHECK IF IT'S THE FIRST TIME THE USER OPENS THE APP

      final bool isFirstTime = await ref.read(isFirstTimeProvider.future);
      if (isFirstTime) return '/register-decision';

      debugPrint('Route: it is not the first time the user opens the app');

      // CHECK IF THE USER IS AUTHENTICATED

      final bool isAuthenticated = ref.read(isAuthenticatedProvider);
      if (isAuthenticated == false) return '/login';

      debugPrint('Route: user is authenticated');

      // CHECK IF THE USER HAS A FIRESTORE DOCUMENT

      UserModel? currentUser = ref.read(userControllerProvider);

      if (currentUser == null) {
        final userResult = await ref.read(getCurrentUserModelFromFirestoreProvider.future);
        currentUser = userResult.data;
      }

      if (currentUser == null) return '/login';

      debugPrint('Route: currentUser id is ${currentUser.id}');

      // CHECK FOR A SUBSCRIPTION

      // THIS SHOULD BE RESTRUCTURED TO HANDLE MULTIPLE SUBSCRIPTIONS

      (SubscriptionModel?, SubscriptionModel?) subscriptionModel = ref.read(subscriptionControllerProvider);
      SubscriptionModel? patientSubscription = subscriptionModel.$1;
      SubscriptionModel? therapistSubscription = subscriptionModel.$2;

      if (patientSubscription == null && therapistSubscription == null) {
        debugPrint('Route: subscriptionModel is initially null, trying to query it from db');
        final subscriptionResult = await ref.read(getCurrentUserSubscriptionProvider.future);
        debugPrint('Route: subscriptionResult is $subscriptionResult');
        final patientSubscriptionModel = subscriptionResult.$1.data;
        final therapistSubscriptionModel = subscriptionResult.$2.data;
        if (patientSubscriptionModel == null && therapistSubscriptionModel == null) return '/subscription-options';
        debugPrint(
            'Route: patientSubscriptionModel id is ${patientSubscriptionModel?.id} and therapistSubscriptionModel id is ${therapistSubscriptionModel?.id}');
      }

      // CHECK FOR PATIENTS WITHOUT THERAPISTS

      final currentUserRole = currentUser.role;

      if (currentUserRole == RoleEnum.patient) {
        final List<String> therapists = currentUser.therapistId;
        final List<String> invitations = currentUser.invitationId;
        debugPrint('Route: currentUserRole is patient and there are ${therapists.length} therapists and ${invitations.length} invitations');
      }

      return desiredRoute;
    } catch (e) {
      debugPrint('Route: error in build method: $e');
      return backupRoute ?? '/login';
    }
  }
}
