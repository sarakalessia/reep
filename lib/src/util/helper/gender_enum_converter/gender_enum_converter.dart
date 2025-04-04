import 'package:flutter/material.dart';
import 'package:repathy/src/util/enum/gender_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GenderEnumConverter {
  
  static GenderEnum fromString(String gender) {
    final lowerCaseGender = gender.toLowerCase();
    switch (lowerCaseGender) {
      case 'uomo':
        return GenderEnum.male;
      case 'donna':
        return GenderEnum.female;
      default:
        return GenderEnum.other;
    }
  }

  static String toLocalizedString(BuildContext context, RoleEnum? role, GenderEnum genderEnum) {
    switch (genderEnum) {
      case GenderEnum.male:
        return AppLocalizations.of(context)!.man;
      case GenderEnum.female:
        return AppLocalizations.of(context)!.woman;
      case GenderEnum.other:
        return AppLocalizations.of(context)!.other;
    }
  }
}
