import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:repathy/src/page/app_initialization/app_error_widget.dart';
import 'package:repathy/src/page/app_initialization/app_splash_screen.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_interaction_model/media_interaction_model.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/page/authentication/forgot_password_confirmation.dart';
import 'package:repathy/src/page/authentication/forgot_password_page.dart';
import 'package:repathy/src/page/media/video_player_page.dart';
import 'package:repathy/src/page/patient/invite_a_therapist_page.dart';
import 'package:repathy/src/page/subscription/subscription_options_page.dart';
import 'package:repathy/src/page/main_page.dart';
import 'package:repathy/src/controller/route_controller/route_controller.dart';
import 'package:repathy/src/page/subscription/subscription_page.dart';
import 'package:repathy/src/util/helper/snackbar/snackbar.dart';
import 'package:repathy/src/page/patient/invitation_sent_page.dart';
import 'package:repathy/src/page/authentication/login_page.dart';
import 'package:repathy/src/page/patient/qr_code_success_page.dart';
import 'package:repathy/src/page/registration/registration_decision_page.dart';
import 'package:repathy/src/page/registration/registration_page.dart';
import 'package:repathy/src/page/patient/qr_code_scan_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'route.g.dart';

// CAN'T FIND A PAGE?
// IN THIS APP, MANY PAGES ARE JUST SUB-PAGES, SO THEY'RE NOT DECLARED AS NORMAL ROUTES
// TO ADD/EDIT PAGES FOLLOW THESE 3 STEPS:
// STEP 1: lib/src/util/enum/page_enum.dart to find or add a page
// STEP 2: lib/src/controller/current_page_controller/current_page_controller.dart to add business rules
// STEP 3: lib/src/component/page_structure/main_page.dart to add a page to the switch case statement

@riverpod
GoRouter goRouter(Ref ref) {
  debugPrint('Route: goRouter provider is called');

  final router = GoRouter(
    navigatorKey: ref.read(navigatorKeyProvider),
    initialLocation: '/splash-screen',
    errorPageBuilder: (context, state) => const MaterialPage(child: AppErrorPage()),
    routes: <RouteBase>[
      GoRoute(
        path: '/splash-screen',
        pageBuilder: (context, state) {
          debugPrint('Route: about to return AppSplashPage()');
          return const MaterialPage(child: AppSplashPage());
        },
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => const MaterialPage(child: MainPage()),
        redirect: (context, state) async => await ref.read(routeControllerProvider(desiredRoute: null, backupRoute: null).future),
      ),
      GoRoute(
        path: '/register-decision',
        pageBuilder: (context, state) => const MaterialPage(child: RegistrationDecisionPage()),
      ),
      GoRoute(
        path: '/register/:role',
        pageBuilder: (context, state) => MaterialPage(child: RegistrationPage(role: state.pathParameters['role']!)),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const MaterialPage(child: LoginPage()),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => const MaterialPage(child: ForgotPasswordPage()),
      ),
      GoRoute(
        path: '/forgot-password-confirmation',
        pageBuilder: (context, state) => const MaterialPage(child: ForgotPasswordConfirmation()),
      ),
      GoRoute(
        path: '/subscription-options',
        pageBuilder: (context, state) => const MaterialPage(child: SubscriptionOptions()),
      ),
      GoRoute(
        path: '/subscription',
        pageBuilder: (context, state) => const MaterialPage(child: SubscriptionPage()),
      ),
      GoRoute(
        path: '/therapist-invitation',
        pageBuilder: (context, state) {
          final Map<String, dynamic>? extraParamsMap = state.extra != null ? state.extra as Map<String, dynamic> : null;
          final String? scanError = extraParamsMap?['scan-error'] as String?;
          return MaterialPage(child: TherapistInvitationPage(scanError: scanError));
        },
      ),
      GoRoute(
        path: '/invitation-sent',
        pageBuilder: (context, state) {
          final Map<String, dynamic>? extraParamsMap = state.extra != null ? state.extra as Map<String, dynamic> : null;
          final String name = extraParamsMap!['name'] as String;
          final String gender = extraParamsMap['gender'] as String;
          debugPrint('Route: about to return InvitationSentPage() with name: $name and gender: $gender');
          return MaterialPage(child: InvitationSentPage(name: name, gender: gender));
        },
      ),
      GoRoute(
        path: '/scan-qr-code',
        pageBuilder: (context, state) => const MaterialPage(child: ScanQrCodePage()),
      ),
      GoRoute(
        path: '/qr-code-success',
        pageBuilder: (context, state) {
          final Map<String, dynamic>? extraParamsMap = state.extra != null ? state.extra as Map<String, dynamic> : null;
          final String name = extraParamsMap!['name'] as String;
          debugPrint('Route: about to return InvitationSentPage() with name: $name');
          return MaterialPage(child: QrCodeSuccessPage(name: name));
        },
      ),
      GoRoute(
        path: '/video-player',
        pageBuilder: (context, state) {
          final Map<String, dynamic>? extraParamsMap = state.extra != null ? state.extra as Map<String, dynamic> : null;
          final mediaFromParams = extraParamsMap!['media'] as MediaModel;
          final mediaInteractionList = extraParamsMap['interactions'] as List<MediaInteractionModel>?;
          final currentUser = extraParamsMap['currentUser'] as UserModel?;
          return MaterialPage(
              child: VideoPlayerPage(
            mediaModel: mediaFromParams,
            mediaInteractionList: mediaInteractionList,
            currentUser: currentUser,
          ));
        },
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
}
