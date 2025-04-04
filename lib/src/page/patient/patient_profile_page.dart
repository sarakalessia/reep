import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/input/input_dropdown_field.dart';
import 'package:repathy/src/component/input/input_field.dart';
import 'package:repathy/src/component/profile_photo/profile_photo.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/controller/profile_image_controller/profile_image_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/util/key/keys.dart';
import 'package:repathy/src/util/enum/gender_enum.dart';
import 'package:repathy/src/util/helper/gender_enum_converter/gender_enum_converter.dart';

class PatientProfilePage extends ConsumerStatefulWidget {
  const PatientProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends ConsumerState<PatientProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  String? therapistId;

  @override
  void initState() {
    loadDependencies();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    birthDateController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> loadDependencies() async {
    final user = ref.read(userControllerProvider);
    if (user == null) return;

    nameController.text = user.name ?? '';
    lastNameController.text = user.lastName ?? '';
    emailController.text = user.email ?? '';
    final DateTime? birthDate = user.birthDate;
    if (birthDate != null) birthDateController.text = DateFormat('dd/MM/yyyy').format(birthDate);
    heightController.text = user.height?.toString() ?? '';
    weightController.text = user.weight?.toString() ?? '';
    therapistId = user.therapistId.firstOrNull;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userControllerProvider);
    final image = ref.watch(imageFromCurrentUserProvider(isCover: false));
    final initialGender = GenderEnumConverter.toLocalizedString(context, user!.role, user.gender);
    debugPrint('View: initialGender is $initialGender and items are ${AppLocalizations.of(context)!.man}, ${AppLocalizations.of(context)!.woman}');

    return Flexible(
      child: SingleChildScrollView(
        child: Form(
          key: therapistProfileKey,
          child: Column(
            children: [
              ProfilePhoto(image: image),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: InputFormField(
                      controller: nameController,
                      name: AppLocalizations.of(context)!.name,
                      validator: (value) => ref.read(formControllerProvider.notifier).validateEmptyOrNull(value, context),
                    ),
                  ),
                  Flexible(
                    child: InputFormField(
                      controller: lastNameController,
                      name: AppLocalizations.of(context)!.lastName,
                      validator: (value) => ref.read(formControllerProvider.notifier).validateEmptyOrNull(value, context),
                    ),
                  ),
                ],
              ),
              InputFormField(
                controller: emailController,
                name: AppLocalizations.of(context)!.email,
                validator: (value) => ref.read(formControllerProvider.notifier).validateEmail(value, context),
                shouldCapitalizeSentence: false,
                isReadOnly: true,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: InputFormField(
                      controller: birthDateController,
                      name: AppLocalizations.of(context)!.birthDate,
                      validator: (value) => ref.read(formControllerProvider.notifier).validateDate(value, context),
                      suffixIcon: const Icon(Icons.calendar_today),
                      isDate: true,
                    ),
                  ),
                  Flexible(
                    child: InputDropdownField(
                      initialValue: GenderEnumConverter.toLocalizedString(context, user.role, user.gender),
                      items: [AppLocalizations.of(context)!.man, AppLocalizations.of(context)!.woman, AppLocalizations.of(context)!.other],
                      name: AppLocalizations.of(context)!.gender,
                      validator: (String? value) => ref.read(formControllerProvider.notifier).validateGender(value, context),
                      onChanged: (String? value) {
                        if (value == null) return;
                        final updatedUser = user.copyWith(gender: GenderEnumConverter.fromString(value));
                        ref.read(userControllerProvider.notifier).updateCachedUser(updatedUser);
                      },
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: InputFormField(
                      controller: heightController,
                      name: AppLocalizations.of(context)!.height,
                      validator: (value) => ref.read(formControllerProvider.notifier).validateOptionalField(value),
                    ),
                  ),
                  Flexible(
                    child: InputFormField(
                      controller: weightController,
                      name: AppLocalizations.of(context)!.weight,
                      validator: (value) => ref.read(formControllerProvider.notifier).validateOptionalField(value),
                    ),
                  ),
                ],
              ),
              // TherapistTileButton(therapistId: therapistId),
              SizedBox(height: 100),
              PrimaryButton(
                text: AppLocalizations.of(context)!.save,
                onPressed: () async {
                  ref.read(formControllerProvider.notifier).handleEditForm(
                    actions: [
                      () async {
                        final GenderEnum genderEnum = ref.read(userControllerProvider)!.gender;
                        final GenderEnum chosenGender = genderEnum == GenderEnum.other ? user.gender : genderEnum;
                        debugPrint('View: genderEnum is $genderEnum and chosenGender is $chosenGender');
                        debugPrint('View: userController before updating is ${ref.read(userControllerProvider)}');
                        debugPrint('View: nameController is ${nameController.text}, lastNameController is ${lastNameController.text}, emailController is ${emailController.text}, birthDateController is ${birthDateController.text}, weightController is ${weightController.text}, heightController is ${heightController.text}, chosenGender is $chosenGender');
                        return await ref.read(userControllerProvider.notifier).updateUserDocument(
                              name: nameController.text,
                              lastName: lastNameController.text,
                              email: emailController.text,
                              birthDate: ref.read(formControllerProvider.notifier).parseDate(birthDateController.text),
                              weight: double.tryParse(weightController.text),
                              height: double.tryParse(heightController.text),
                              gender: chosenGender,
                            );
                      },
                    ],
                    onEnd: [
                      () => ref.read(userControllerProvider.notifier).syncCachedUserWithDatabase(),
                    ],
                    globalKey: therapistProfileKey,
                    context: context,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
