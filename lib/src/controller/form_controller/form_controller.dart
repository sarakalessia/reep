// ignore_for_file: avoid_build_context_in_providers
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/util/helper/snackbar/snackbar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'form_controller.g.dart';

@riverpod
class FormController extends _$FormController {
  @override
  bool build() => true;

  void setStateToFalse() => state = false; // loading
  void setStateToTrue() => state = true; // available

  bool isEmail(String input) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(input);
  }

  bool comparePasswords(String firstPassword, String secondPassword) => firstPassword == secondPassword ? true : false;

  String? validateEmail(String? value, BuildContext context) {
    debugPrint('Controller: validateEmail is $value');
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.emailIsMandatory;
    } else if (!ref.read(formControllerProvider.notifier).isEmail(value)) {
      setStateToFalse();
      return AppLocalizations.of(context)!.emailValidator;
    }
    return null;
  }

  String? validatePassword(String? value, BuildContext context) {
    debugPrint('first password is $value');
    if (value == null) {
      setStateToFalse();
      return AppLocalizations.of(context)!.passwordValidatorMandatory;
    } else if (value.trim().length < 6) {
      return AppLocalizations.of(context)!.passwordValidatorMandatory;
    }
    return null;
  }

  String? validateDate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.birthDateFieldIsMandatory;
    }

    final RegExp dateRegExp = RegExp(
      r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/(19|20)\d\d$',
    );

    if (!dateRegExp.hasMatch(value)) {
      return AppLocalizations.of(context)!.birthDayFormatIsDDMMYYYY;
    }

    return null;
  }

  String? validateEmptyOrNull(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      setStateToFalse();
      return AppLocalizations.of(context)!.fieldIsMandatory;
    }
    return null;
  }

  String? validateOptionalField(String? value) => null;

  String? validateGender(String? value, BuildContext context) {
    String? lowerStringValue;
    if (value != null) {
      lowerStringValue = value.toLowerCase();
    } else {
      lowerStringValue = value;
    }
    if (lowerStringValue == 'uomo' || lowerStringValue == 'donna' || lowerStringValue == 'terapista' || lowerStringValue == 'terapista') {
      return null;
    } else {
      return AppLocalizations.of(context)!.genderFieldIsMandatory;
    }
  }

  Future<void> handleForm({
    List<Function()>? actions,
    List<Function()>? onEnd,
    String? route,
    required GlobalKey<FormState> globalKey,
    required BuildContext context,
  }) async {
    try {
      setStateToFalse();
      debugPrint('Controller: handleForm loading state is $state, trying to validate form');
      final isValid = globalKey.currentState!.validate();
      debugPrint('Controller: handleForm value of isValid is $isValid');

      if (!isValid) {
        ref.read(snackBarProvider(text: AppLocalizations.of(context)!.formControllerFormValidator));
        setStateToTrue();
        return;
      }
      globalKey.currentState!.save();
      debugPrint('Controller: handleForm form is validated');

      if (actions == null || actions.isEmpty) {
        debugPrint('Controller: handleForm navigating without action');
        setStateToTrue();
        if (route != null) ref.read(goRouterProvider).go(route);
        return;
      }

      for (var action in actions) {
        final ResultModel<dynamic> actionResult = await action();
        if (actionResult.error != null) {
          // if (context.mounted) ref.read(snackBarProvider(text: actionResult.error!));
          setStateToTrue();
          return;
        }
      }

      debugPrint('Controller: handleForm main functions executed, moving to onEnd');

      if (onEnd != null) {
        for (var action in onEnd) {
          action();
        }
      }

      debugPrint('Controller: handleForm about to navigate');
      setStateToTrue();
      if (route != null) ref.read(goRouterProvider).go(route);
    } catch (error) {
      if (context.mounted) ref.read(snackBarProvider(text: AppLocalizations.of(context)!.formError));
      debugPrint('Controller: handleForm error is $error');
      setStateToTrue();
    }
  }

  Future<void> handleEditForm({
    List<Function()>? actions,
    List<Function()>? onEnd,
    required GlobalKey<FormState> globalKey,
    required BuildContext context,
  }) async {
    try {
      setStateToFalse();
      debugPrint('Controller: handleForm loading state is $state, trying to validate form');
      final isValid = globalKey.currentState!.validate();
      debugPrint('Controller: handleForm value of isValid is $isValid');

      if (!isValid) {
        ref.read(snackBarProvider(text: AppLocalizations.of(context)!.formControllerFormValidator));
        setStateToTrue();
        return;
      }
      globalKey.currentState!.save();
      debugPrint('Controller: handleForm form is validated');

      if (actions == null || actions.isEmpty) {
        debugPrint('Controller: handleForm navigating without action');
        setStateToTrue();
        return;
      }

      for (var action in actions) {
        final ResultModel<dynamic> actionResult = await action();
        if (actionResult.error != null) {
          if (context.mounted) ref.read(snackBarProvider(text: actionResult.error!));
          setStateToTrue();
          return;
        }
      }

      debugPrint('Controller: handleForm main functions executed, moving to onEnd');

      if (onEnd != null) {
        for (var action in onEnd) {
          action();
        }
      }

      debugPrint('Controller: handleForm about to navigate');
      setStateToTrue();
      if (context.mounted) {
        ref.read(snackBarProvider(text: AppLocalizations.of(context)!.snackBarSuccess, successOrFail: true));
      }
    } catch (error) {
      if (context.mounted) ref.read(snackBarProvider(text: AppLocalizations.of(context)!.formError));
      debugPrint('Controller: handleForm error is $error');
      setStateToTrue();
    }
  }

  DateTime? parseDate(String dateString) {
    try {
      final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
      return dateFormat.parse(dateString);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return null;
    }
  }

  int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
