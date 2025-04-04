// ignore_for_file: avoid_build_context_in_providers
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/bottom_nav_bar_controller/bottom_nav_bar_controller.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/media_format_enum.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_page_controller.g.dart';

@riverpod
class CurrentPageController extends _$CurrentPageController {
  @override
  PageEnum build(BuildContext context) {
    final int navBarIndexController = ref.watch(bottomNavBarIndexProvider);
    final UserModel? currentUser = ref.watch(userControllerProvider);
    final PageEnum subPageController = ref.watch(subPageControllerProvider);
    final RoleEnum role = currentUser?.role ?? RoleEnum.unknown;

    debugPrint(
        'Controller: currentPageController role is: $role, index is: $navBarIndexController and subpage is: $subPageController');

    if (navBarIndexController == 0 && role == RoleEnum.patient && subPageController == PageEnum.none) {
      debugPrint('Controller: currentPageController PageEnum.profile');
      return PageEnum.patientProfile;
    } else if (navBarIndexController == 1 && role == RoleEnum.patient && subPageController == PageEnum.none) {
      debugPrint('Controller: currentPageController PageEnum.patientHome');
      return PageEnum.patientHome;
    } else if (navBarIndexController == 2 && role == RoleEnum.patient && subPageController == PageEnum.none) {
      debugPrint('Controller: currentPageController PageEnum.painTypes');
      return PageEnum.painTypes;
    } else if (navBarIndexController == 0 && role == RoleEnum.therapist && subPageController == PageEnum.none) {
      debugPrint('Controller: currentPageController PageEnum.PatientListPage');
      return PageEnum.patientListPage;
    } else if (navBarIndexController == 1 && role == RoleEnum.therapist && subPageController == PageEnum.none) {
      debugPrint('Controller: currentPageController PageEnum.therapistHome');
      return PageEnum.therapistHome;
    } else if (navBarIndexController == 2 && role == RoleEnum.therapist && subPageController == PageEnum.none) {
      debugPrint('Controller: currentPageController PageEnum.library');
      return PageEnum.library;
    } else if (role == RoleEnum.therapist && subPageController == PageEnum.patientDetail) {
      debugPrint('Controller: currentPageController PageEnum.PatientListPage');
      return PageEnum.patientDetail;
    } else if (role == RoleEnum.therapist && subPageController == PageEnum.therapistProfile) {
      debugPrint('Controller: currentPageController PageEnum.therapistProfile');
      return PageEnum.therapistProfile;
    } else if (role == RoleEnum.therapist && subPageController == PageEnum.newVideo) {
      debugPrint('Controller: currentPageController PageEnum.newVideo');
      return PageEnum.newVideo;
    } else if (role == RoleEnum.therapist && subPageController == PageEnum.newPdf) {
      debugPrint('Controller: currentPageController PageEnum.newPdf');
      return PageEnum.newPdf;
    } else if (role == RoleEnum.therapist && subPageController == PageEnum.pdfPreview) {
      debugPrint('Controller: currentPageController PageEnum.pdfPreview');
      return PageEnum.pdfPreview;
    } else if (role == RoleEnum.therapist && subPageController == PageEnum.videoDetail) {
      debugPrint('Controller: currentPageController PageEnum.videoDetail');
      return PageEnum.videoDetail;
    } else if (role == RoleEnum.therapist && subPageController == PageEnum.linkMediaToPatient) {
      debugPrint('Controller: currentPageController PageEnum.linkMediaToPatient');
      return PageEnum.linkMediaToPatient;
    } else if (role == RoleEnum.therapist && subPageController == PageEnum.patientTransfer) {
      debugPrint('Controller: currentPageController PageEnum.patientTransfer');
      return PageEnum.patientTransfer;
    } else if (role == RoleEnum.patient && subPageController == PageEnum.patientProfile) {
      debugPrint('Controller: currentPageController PageEnum.patientProfile');
      return PageEnum.patientProfile;
    } else if (role == RoleEnum.patient && subPageController == PageEnum.patientLibrary) {
      debugPrint('Controller: currentPageController PageEnum.patientLibrary');
      return PageEnum.patientLibrary;
    } else if (role == RoleEnum.patient && subPageController == PageEnum.therapistPublicProfile) {
      debugPrint('Controller: currentPageController PageEnum.therapistPublicProfile');
      return PageEnum.therapistPublicProfile;
    } else if (subPageController == PageEnum.videoPlayer) {
      debugPrint('Controller: currentPageController PageEnum.videoPlayer');
      return PageEnum.videoPlayer;
    } else if (subPageController == PageEnum.videoDetail) {
      debugPrint('Controller: currentPageController PageEnum.videoDetail');
      return PageEnum.videoDetail;
    } else if (subPageController == PageEnum.notifications) {
      debugPrint('Controller: currentPageController PageEnum.notifications');
      return PageEnum.notifications;
    } else if (subPageController == PageEnum.settings) {
      debugPrint('Controller: currentPageController PageEnum.settings');
      return PageEnum.settings;
    } else if (subPageController == PageEnum.licenses) {
      debugPrint('Controller: currentPageController PageEnum.licenses');
      return PageEnum.licenses;
    } else if (subPageController == PageEnum.support) {
      debugPrint('Controller: currentPageController PageEnum.support');
      return PageEnum.support;
    } else if (subPageController == PageEnum.privacyPolicy) {
      debugPrint('Controller: currentPageController PageEnum.privacyPolicy');
      return PageEnum.privacyPolicy;
    } else if (subPageController == PageEnum.termsOfService) {
      debugPrint('Controller: currentPageController PageEnum.termsOfService');
      return PageEnum.termsOfService;
    } else {
      debugPrint('Controller: currentPageController PageEnum.unknown');
      return PageEnum.unknown;
    }
  }
}

@Riverpod(keepAlive: true)
class SubPageController extends _$SubPageController {
  @override
  PageEnum build() => PageEnum.none;

  void updateSubPage(PageEnum page) => state = page;

  void navigateToSubPage({required int index, required PageEnum subPage}) {
    ref.read(bottomNavBarIndexProvider.notifier).setIndex(index);
    updateSubPage(subPage);
  }
}

@Riverpod(keepAlive: true)
bool isMainPage(Ref ref, BuildContext context) {
  final currentPage = ref.watch(currentPageControllerProvider(context));
  switch (currentPage) {
    case PageEnum.patientProfile:
    case PageEnum.patientHome:
    case PageEnum.painTypes:
    case PageEnum.patientListPage:
    case PageEnum.therapistHome:
    case PageEnum.library:
      return true;
    default:
      return false;
  }
}

@Riverpod(keepAlive: true)
double returnPaddingBasedOnPage(Ref ref, BuildContext context) {
  final currentPage = ref.watch(currentPageControllerProvider(context));
  switch (currentPage) {
    case PageEnum.patientListPage:
      return 14;
    case PageEnum.therapistHome:
      return 14;
    case PageEnum.library:
      return 14;
    case PageEnum.patientProfile:
      return 14;
    case PageEnum.patientHome:
      return 14;
    case PageEnum.painTypes:
      return 14;
    case PageEnum.therapistProfile:
      return 0;
    case PageEnum.newVideo:
      return 14;
    case PageEnum.linkMediaToPatient:
      return 14;
    case PageEnum.patientDetail:
      return 14;
    case PageEnum.newPdf:
      return 14;
    case PageEnum.pdfPreview:
      return 14;
    case PageEnum.therapistPublicProfile:
      return 14;
    case PageEnum.patientLibrary:
      return 14;
    case PageEnum.videoDetail:
      return 14;
    case PageEnum.settings:
      return 14;
    case PageEnum.licenses:
      return 14;
    case PageEnum.notifications:
      return 14;
    case PageEnum.patientTransfer:
      return 14;
    case PageEnum.unknown:
    default:
      return 14;
  }
}

@Riverpod(keepAlive: true)
bool shouldExtendBehindAppBar(Ref ref, BuildContext context) {
  final currentPage = ref.watch(currentPageControllerProvider(context));
  switch (currentPage) {
    case PageEnum.patientListPage:
      return false;
    case PageEnum.therapistHome:
      return false;
    case PageEnum.library:
      return false;
    case PageEnum.patientProfile:
      return false;
    case PageEnum.patientHome:
      return false;
    case PageEnum.painTypes:
      return false;
    case PageEnum.therapistProfile:
      return true;
    case PageEnum.newVideo:
      return false;
    case PageEnum.linkMediaToPatient:
      return false;
    case PageEnum.patientDetail:
      return false;
    case PageEnum.newPdf:
      return false;
    case PageEnum.pdfPreview:
      return false;
    case PageEnum.therapistPublicProfile:
      return false;
    case PageEnum.patientLibrary:
      return false;
    case PageEnum.videoDetail:
      return false;
    case PageEnum.videoPlayer:
      return false;
    case PageEnum.settings:
      return false;
    case PageEnum.licenses:
      return false;
    case PageEnum.notifications:
      return false;
    case PageEnum.patientTransfer:
      return false;
    case PageEnum.support:
      return false;
    case PageEnum.privacyPolicy:
      return false;
    case PageEnum.termsOfService:
      return false;
    case PageEnum.none:
    case PageEnum.unknown:
      return false;
  }
}

@Riverpod(keepAlive: true)
(int index, PageEnum pageEnum) getReturnRoute(Ref ref, BuildContext context) {
  final currentPage = ref.watch(currentPageControllerProvider(context));
  switch (currentPage) {
    case PageEnum.patientHome:
    case PageEnum.painTypes:
    case PageEnum.patientListPage:
    case PageEnum.therapistHome:
    case PageEnum.library:
    case PageEnum.patientProfile:
    case PageEnum.therapistPublicProfile:
    case PageEnum.therapistProfile:
    case PageEnum.settings:
    case PageEnum.notifications:
      return (1, PageEnum.none);
    case PageEnum.patientLibrary:
    case PageEnum.videoDetail:
    case PageEnum.newVideo:
    case PageEnum.newPdf:
      return (2, PageEnum.none);
    case PageEnum.licenses:
    case PageEnum.support:
    case PageEnum.privacyPolicy:
    case PageEnum.termsOfService:
      return (1, PageEnum.settings);
    case PageEnum.linkMediaToPatient:
      final currentMedia = ref.read(mediaControllerProvider);
      final mediaType = currentMedia?.mediaFormat;
      if (mediaType == MediaFormatEnum.pdf) return (2, PageEnum.pdfPreview);
      return (2, PageEnum.newVideo);
    case PageEnum.pdfPreview:
      return (2, PageEnum.newPdf);
    case PageEnum.videoPlayer:
      return (2, PageEnum.videoDetail);
    case PageEnum.patientTransfer:
    case PageEnum.patientDetail:
      return (0, PageEnum.none);
    case PageEnum.unknown:
    case PageEnum.none:
      return (1, PageEnum.none);
  }
}
