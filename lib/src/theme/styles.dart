import 'package:flutter/material.dart';

class RepathyStyle {
// ------------------ GLOBAL ------------------

// FONT
  static const String primaryFont = 'Outfit';

// TEXT SIZE
  static const double giantTextSize = 40;
  static const double extraLargeTextSize = 30;
  static const double largeTextSize = 25;
  static const double standardTextSize = 18;
  static const double smallTextSize = 16;
  static const double miniTextSize = 14;

// FONT WEIGHT
  static const FontWeight boldFontWeight = FontWeight.w700;
  static const FontWeight semiBoldFontWeight = FontWeight.w600;
  static const FontWeight standardFontWeight = FontWeight.w500;
  static const FontWeight lightFontWeight = FontWeight.w400;

// BORDER RADIUS
  static const double roundedRadius = 30;
  static const double standardRadius = 12;
  static const double lightRadius = 8;

// ICON SIZE
  static const double extraLargeIconSize = 64;
  static const double giantIconSize = 56;
  static const double largeIconSize = 48;
  static const double standardIconSize = 33;
  static const double smallIconSize = 24;
  static const double miniIconSize = 20;
  static const double atomIconSize = 8;

// COLOR
  static const Color primaryColor = Color(0xFF62C6C9);
  static const Color primaryColorWithOpacity = Color(0x3B62C6C9);
  static const Color lightPrimaryColor = Color(0xFFAFDEDC);
  static const Color secondaryColor = Color(0xFF3B9FDF);
  static const Color backgroundColor = Color(0xFFFEFEFE);
  static const Color slightlyDarkerBackgroundColor = Color(0xFFFCFCFC);
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFF3F3F3);
  static const Color lightBorderColor = Color(0xEEEEEEEE);
  static const Color lightTextColor = Color(0x464F524D);
  static const Color defaultTextColor = Color(0xFF464F52);
  static const Color darkTextColor = Color(0xFF000000);
  static const Color successColor = Color(0xFF00BCA5);
  static const Color removeColor = Color(0xFFD95F5F);
  static const Color errorColor = Color(0xFFFD6E35);

// GRADIENT COLORS

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF01FCC6),
      Color(0xFF03EFFB),
    ],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF62C6C9),
      Color(0xFF3B9FDF),
    ],
  );

// ------------------ COMPONENT ------------------

// SIDE MENU
  static const double sideMenuWidth = 263;
  static const double sideMenuBorderSize = 44;
  static const double sideMenusItemText = 16;
  static const double sideMenuUserNameSize = 20;
  static const double sideMenuStudioNameSize = 18;
  static const double sideMenuProfileImage = 61;

// BUTTON
  static const double buttonWidthStandard = 333;
  static const double buttonHeightStandard = 61;

  static const double buttonWidthMedium = 280;
  static const double buttonHeightMedium = 48;

  static const double buttonWidthSmall = 210;
  static const double buttonHeightSmall = 40;

  static const double buttonWidthMini = 170;
  static const double buttonHeightMini = 28;

// SECTION CARD
  static const double sectionCardHeight = 138;
  static const double sectionCardWidth = 329;

// THERAPIST CARD
  static const double therapistCardHeight = 103;
  static const double therapistCardWidth = 329;
  static const double therapistCardDescriptionSize = 18;

// NOTIFICATION CARD
  static const double notificationCardDescriptionText = 14;

// ANNOUNCEMENT CARD
  static const double announcementCardHeight = 175;

// INPUT FIELD
  static const double inputFieldHeight = 48;
  static const Color inputFieldHintTextColor = Color.fromARGB(255, 196, 196, 196);
  static const Color inputFieldTextColor = Color(0xFF000000);
  static const Color smallIconColor = Color(0xFF677294);

// CARD
  static const double cardMaxWidth = 353;
  static const double cardHeight = 70;

// APP BAR
  static const double appBarHeight = 147;
  static const Color appBarIconColor = Color(0xFF323232);

// BOTTOM NAVIGATION
  static const double bottomNavigationHeight = 108;
  static const Color bottomNavigationIconColor = Color(0xFF858EA9);

// BOTTOM SHEET
  static const double bottomSheetHeight = 473;
}
