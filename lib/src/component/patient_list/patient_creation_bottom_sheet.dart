import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/input/input_dropdown_field.dart';
import 'package:repathy/src/component/input/input_field.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/util/key/keys.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/util/helper/gender_enum_converter/gender_enum_converter.dart';
import 'package:repathy/src/util/helper/snackbar/snackbar.dart';

class PatientCreationBottomSheet extends ConsumerStatefulWidget {
  const PatientCreationBottomSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PatientCreationBottomSheetState();
}

class _PatientCreationBottomSheetState extends ConsumerState<PatientCreationBottomSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    birthDateController.dispose();
    genderController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.9,
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(RepathyStyle.roundedRadius),
          topRight: Radius.circular(RepathyStyle.roundedRadius),
        ),
      ),
      child: Form(
        key: internalRegistrationKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: RepathyStyle.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              PageTitleText(title: 'Nuovo paziente', top: 32, bottom: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: InputFormField(
                      focusNode: focusNode,
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
              InputFormField(
                controller: birthDateController,
                name: '${AppLocalizations.of(context)!.birthDate}*',
                validator: (value) => ref.read(formControllerProvider.notifier).validateDate(value, context),
                suffixIcon: const Icon(Icons.calendar_today),
                isDate: true,
              ),
              InputDropdownField(
                items: [AppLocalizations.of(context)!.man, AppLocalizations.of(context)!.woman],
                name: '${AppLocalizations.of(context)!.gender}*',
                validator: (String? value) => ref.read(formControllerProvider.notifier).validateGender(value, context),
                onChanged: (String? value) {
                  if (value == null) return;
                  genderController.text = value;
                },
              ),
              InputFormField(
                controller: emailController,
                name: '${AppLocalizations.of(context)!.email}*',
                validator: (value) => ref.read(formControllerProvider.notifier).validateEmail(value, context),
              ),
              PrimaryButton(
                text: AppLocalizations.of(context)!.confirmRequestButton,
                onPressed: () async {
                  ref.read(formControllerProvider.notifier).handleForm(
                    globalKey: internalRegistrationKey,
                    context: context,
                    actions: [
                      () async => await ref.read(userControllerProvider.notifier).handleUserCreation(
                            email: emailController.text,
                            name: nameController.text,
                            lastName: lastNameController.text,
                            role: RoleEnum.patient,
                            birthDate: ref.read(formControllerProvider.notifier).parseDate(birthDateController.text),
                            password: null,
                            gender: GenderEnumConverter.fromString(genderController.text),
                            createdByTherapist: true,
                          ),
                    ],
                    onEnd: [
                      () => ref.refresh(asyncFilteredPatientsProvider(includeTemporaryPatients: true)),
                      () async => await ref.read(userControllerProvider.notifier).syncCachedUserWithDatabase(),
                      () => Navigator.of(context).pop(),
                      () => ref.read(snackBarProvider(text: 'Paziente creato con successo', successOrFail: true)),
                    ],
                  );
                },
              ),
              SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }
}
