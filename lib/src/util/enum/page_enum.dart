import 'package:freezed_annotation/freezed_annotation.dart';

// This project works with a main page vs sub-page navigation system
// Main pages are the ones that are shown in the bottom navigation bar
// Sub-pages are the ones that you can only access from the main pages
// Traditional route navigation is only used for login, registration, reset password, etc

// The files that complement this are:
// lib/src/controller/current_page_controller/current_page_controller.dart ||  Provider that returns the current page's PageEnum
// lib/src/page/main_page.dart                                             ||  Renders the content based on PageEnum
// lib/src/controller/route_controller/route_controller.dart               ||  Business rules for each page, redirects, etc
// lib/route/route.dart                                                    ||  Traditional route navigation

enum PageEnum {
  // THERAPIST MAIN PAGES, CAN BE ACCESSED FROM THE BOTTOM NAVIGATION BAR
  @JsonValue("patientListPage")
  patientListPage,
  @JsonValue("therapistHome")
  therapistHome,
  @JsonValue("library")
  library,

  // PATIENT MAIN PAGES, CAN BE ACCESSED FROM THE BOTTOM NAVIGATION BAR
  @JsonValue("patientHome")
  patientHome,
  @JsonValue("painTypes")
  painTypes,
  @JsonValue("patientDetail")
  patientDetail,

  // THERAPIST SUBPAGES
  @JsonValue("newVideo")
  newVideo,
  @JsonValue("newPdf")
  newPdf,
  @JsonValue("linkMediaToPatient")
  linkMediaToPatient,
  @JsonValue("pdfPreview")
  pdfPreview,
  @JsonValue("therapistProfile")
  therapistProfile,
  @JsonValue("patientTransfer")
  patientTransfer,

  // PATIENTS SUBPAGES
  @JsonValue("patientLibrary")
  patientLibrary,
  @JsonValue("therapistPublicProfile")
  therapistPublicProfile,
  @JsonValue("patientProfile")
  patientProfile,

  // GENERIC SUBPAGES
  @JsonValue("videoDetail")
  videoDetail,
  @JsonValue("videoPlayer")
  videoPlayer,

  // SETTINGS

  @JsonValue("settings")
  settings,
  @JsonValue("licenses")
  licenses,
  @JsonValue("support")
  support,
  @JsonValue("privacyPolicy")
  privacyPolicy,
  @JsonValue("termsOfService")
  termsOfService,

  // NOTIFICATIONS
  @JsonValue("notifications")
  notifications,

  // ERROR CONTROL
  @JsonValue("unknown")
  unknown,

  // USEFUL AS A DEFAULT VALUE
  @JsonValue("none") 
  none,
}
