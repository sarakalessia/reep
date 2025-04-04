import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/app_bar/app_bar.dart';
import 'package:repathy/src/component/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:repathy/src/component/side_menu/side_menu.dart';
import 'package:repathy/src/controller/bottom_nav_bar_controller/bottom_nav_bar_controller.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/page/patient/my_therapist_public_profile.dart';
import 'package:repathy/src/page/therapist/therapist_profile_page.dart';
import 'package:repathy/src/page/therapist/therapist_home_page.dart';
import 'package:repathy/src/page/therapist/therapist_library_page.dart';
import 'package:repathy/src/page/therapist/patient_details_page.dart';
import 'package:repathy/src/page/therapist/patient_list_page.dart';
import 'package:repathy/src/page/therapist/patient_transfer_page.dart';
import 'package:repathy/src/page/patient/patient_media_page.dart';
import 'package:repathy/src/page/notification/notifications_page.dart';
import 'package:repathy/src/page/patient/pain_types_page.dart';
import 'package:repathy/src/page/patient/patient_home_page.dart';
import 'package:repathy/src/page/patient/patient_profile_page.dart';
import 'package:repathy/src/page/media/media_details_page.dart';
import 'package:repathy/src/page/settings/subscription_page.dart';
import 'package:repathy/src/page/therapist/therapist_link_media_page.dart';
import 'package:repathy/src/page/therapist/therapist_new_pdf_page.dart';
import 'package:repathy/src/page/therapist/therapist_new_video_page.dart';
import 'package:repathy/src/page/therapist/therapist_pdf_preview_page.dart';
import 'package:repathy/src/util/enum/page_enum.dart';

import 'settings/settings_page.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  Widget build(BuildContext context) {
    final PageEnum currentPage = ref.watch(currentPageControllerProvider(context));
    final bool bottomNavBarVisibility = ref.watch(bottomNavBarVisibilityProvider(context));
    final bool shouldExtend = ref.watch(shouldExtendBehindAppBarProvider(context));
    final double padding = ref.read(returnPaddingBasedOnPageProvider(context));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: false,
      extendBodyBehindAppBar: shouldExtend,
      appBar: AppBarWidget(),
      endDrawer: const SideMenu(),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildPageView(currentPage)]
        ),
      ),
      bottomNavigationBar: bottomNavBarVisibility ? const BottomNavBar() : null,
    );
  }

  Widget _buildPageView(PageEnum currentPageSync) {
    String buttonText;
    switch (currentPageSync) {
      case PageEnum.patientListPage:
        return const PatientListPage();
      case PageEnum.therapistHome:
        return const TherapistHomePage();
      case PageEnum.library:
        return const TherapistLibraryPage();
      case PageEnum.patientProfile:
        return const PatientProfilePage();
      case PageEnum.patientHome:
        return PatientHomePage();
      case PageEnum.painTypes:
        return const PainTypesPage();
      case PageEnum.therapistProfile:
        return const TherapistProfilePage();
      case PageEnum.newVideo:
        return const TherapistNewVideoPage();
      case PageEnum.linkMediaToPatient:
        return const TherapistLinkMediaPage();
      case PageEnum.patientDetail:
        return const PatientDetailsPage();
      case PageEnum.newPdf:
        return const TherapistNewPdfPage();
      case PageEnum.pdfPreview:
        return const TherapistPdfPreviewPage();
      case PageEnum.patientTransfer:
        return const PatientTransferPage();
      case PageEnum.therapistPublicProfile:
        return const TherapistPublicProfile();
      case PageEnum.patientLibrary:
        return PatientMediaPage();
      case PageEnum.videoDetail:
        return const VideoDetailsPage();
      case PageEnum.settings:
        return const SettingsPage();
      case PageEnum.licenses:
        return const SubscriptionPage();
      case PageEnum.notifications:
        return const NotificationsPage();
      case PageEnum.unknown:
      default:
        buttonText = 'Unknown Page';
    }

    return ElevatedButton(
      onPressed: () {},
      child: Text(buttonText),
    );
  }
}
