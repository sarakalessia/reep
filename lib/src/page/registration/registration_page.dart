import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/input/input_dropdown_field.dart';
import 'package:repathy/src/component/input/input_field.dart';
import 'package:repathy/src/component/input/input_password_field.dart';
import 'package:repathy/src/component/page_structure/login_or_register_structure.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/key/keys.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/util/enum/gender_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/util/helper/gender_enum_converter/gender_enum_converter.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key, required this.role});

  final String role;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController studioNameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController professionalLicenseController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    studioNameController.dispose();
    birthDateController.dispose();
    professionalLicenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel? userModel = ref.watch(userControllerProvider);

    return LoginOrRegisterStructure(
      primaryButtonTitle: AppLocalizations.of(context)!.registration,
      formKey: registrationKey,
      pageTitle: AppLocalizations.of(context)!.signUp,
      showSecondaryButton: true,
      secondaryButtonPath: '/login',
      secondaryButtonSupportText: AppLocalizations.of(context)!.alreadyRegistered,
      secondaryButtonClickableText: AppLocalizations.of(context)!.login,
      childrenWidgets: [
        if (widget.role == 'patient') ...[
          InputDropdownField(
            items: [AppLocalizations.of(context)!.man, AppLocalizations.of(context)!.woman],
            name: '${AppLocalizations.of(context)!.gender}*',
            validator: (String? value) => ref.read(formControllerProvider.notifier).validateGender(value, context),
            onChanged: (String? value) {
              if (userModel == null || value == null) return;
              final updatedUser = userModel.copyWith(gender: GenderEnumConverter.fromString(value));
              ref.read(userControllerProvider.notifier).updateCachedUser(updatedUser);
            },
          ),
          InputFormField(
            controller: birthDateController,
            name: '${AppLocalizations.of(context)!.birthDate}*',
            validator: (value) => ref.read(formControllerProvider.notifier).validateDate(value, context),
            suffixIcon: const Icon(Icons.calendar_today),
            isDate: true,
          ),
        ],
        if (widget.role == 'therapist') ...[
          Row(
            children: [
              Flexible(
                child: InputFormField(
                  controller: professionalLicenseController,
                  name: AppLocalizations.of(context)!.identificationNumber,
                  validator: (String? value) => ref.read(formControllerProvider.notifier).validateOptionalField(value),
                ),
              ),
            ],
          ),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: InputFormField(
                controller: nameController,
                name: '${AppLocalizations.of(context)!.name}*',
                validator: (value) => ref.read(formControllerProvider.notifier).validateEmptyOrNull(value, context),
              ),
            ),
            Flexible(
              child: InputFormField(
                controller: lastNameController,
                name: '${AppLocalizations.of(context)!.lastName}*',
                validator: (value) => ref.read(formControllerProvider.notifier).validateEmptyOrNull(value, context),
              ),
            ),
          ],
        ),
        if (widget.role == 'therapist') ...[
          InputFormField(
            controller: studioNameController,
            name: AppLocalizations.of(context)!.therapistOffice,
            validator: ref.read(formControllerProvider.notifier).validateOptionalField,
          ),
        ],
        InputFormField(
          shouldCapitalizeSentence: false,
          controller: emailController,
          name: '${AppLocalizations.of(context)!.email}*',
          validator: (value) => ref.read(formControllerProvider.notifier).validateEmail(value, context),
        ),
        InputPasswordField(
          controller: passwordController,
          validator: (value) => ref.read(formControllerProvider.notifier).validatePassword(value, context),
        ),
        InputPasswordField(
          controller: confirmPasswordController,
          validator: (value) => ref.read(formControllerProvider.notifier).validatePassword(value, context),
          isConfirmation: true,
        ),
      ],
      onPressed: () async {
        await ref.read(formControllerProvider.notifier).handleForm(
          actions: [
            () async => await ref.read(userControllerProvider.notifier).handleUserCreation(
                  email: emailController.text,
                  password: passwordController.text,
                  name: nameController.text,
                  lastName: lastNameController.text,
                  role: RoleEnumExtension.fromJson(widget.role),
                  studioName: studioNameController.text,
                  birthDate: ref.read(formControllerProvider.notifier).parseDate(birthDateController.text),
                  professionalLicense: professionalLicenseController.text,
                  gender: userModel?.gender ?? GenderEnum.other,
                ),
            () async => await ref.read(userControllerProvider.notifier).signInWithEmailAndPassword(
                  emailController.text,
                  passwordController.text,
                ),
          ],
          route: '/',
          globalKey: registrationKey,
          context: context,
        );
      },
    );
  }
}
