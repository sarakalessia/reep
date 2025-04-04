import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/cover_photo/cover_photo.dart';
import 'package:repathy/src/component/input/input_field.dart';
import 'package:repathy/src/component/input/input_multi_line_field.dart';
import 'package:repathy/src/component/profile_photo/profile_photo.dart';
import 'package:repathy/src/component/qr_code/qr_code_component_open_button.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/controller/profile_image_controller/profile_image_controller.dart';
import 'package:repathy/src/controller/studio_controller/studio_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/util/key/keys.dart';

class TherapistProfilePage extends ConsumerStatefulWidget {
  const TherapistProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TherapistProfilePageState();
}

class _TherapistProfilePageState extends ConsumerState<TherapistProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressStringController = TextEditingController();
  final TextEditingController studioNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    _loadDependencies();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressStringController.dispose();
    studioNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _loadDependencies() {
    final user = ref.read(userControllerProvider);
    final studio = ref.read(studioControllerProvider);
    if (user == null) return;
    nameController.text = user.name ?? '';
    lastNameController.text = user.lastName ?? '';
    emailController.text = user.email ?? '';
    phoneNumberController.text = user.phoneNumber ?? '';
    addressStringController.text = user.addressString ?? '';
    studioNameController.text = user.studioName ?? '';
    descriptionController.text = user.description ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(userControllerProvider);
    final image = ref.watch(imageFromCurrentUserProvider(isCover: false));
    final cover = ref.watch(imageFromCurrentUserProvider(isCover: true));

    return Flexible(
      child: SingleChildScrollView(
        child: Form(
          key: therapistProfileKey,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.13),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  CoverPhoto(cover: cover),
                  Positioned(
                    top: 60,
                    child: ProfilePhoto(image: image),
                  ),
                ],
              ),
              SizedBox(height: 50),
              QrCodeOpenButton(),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Column(
                  children: [
                    InputMultiLineField(
                      controller: descriptionController,
                      name: AppLocalizations.of(context)!.description,
                      validator: (value) => ref.read(formControllerProvider.notifier).validateOptionalField(value),
                    ),
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
                    // IMPLEMENT ICON TEXTFIELD WITH FUNCTIONALITY TO ADD STUDIO AND SUCH
                    InputFormField(
                      controller: studioNameController,
                      name: AppLocalizations.of(context)!.therapistOffice,
                      validator: (value) => ref.read(formControllerProvider.notifier).validateOptionalField(value),
                    ),
                    InputFormField(
                      controller: addressStringController,
                      name: AppLocalizations.of(context)!.address,
                      validator: (value) => ref.read(formControllerProvider.notifier).validateOptionalField(value),
                    ),
                    InputFormField(
                      controller: phoneNumberController,
                      name: AppLocalizations.of(context)!.phone,
                      validator: (value) => ref.read(formControllerProvider.notifier).validateOptionalField(value),
                    ),
                    InputFormField(
                      controller: emailController,
                      name: AppLocalizations.of(context)!.email,
                      validator: (value) => ref.read(formControllerProvider.notifier).validateEmail(value, context),
                      shouldCapitalizeSentence: false,
                      isReadOnly: true,
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                text: AppLocalizations.of(context)!.save,
                onPressed: () async {
                  await ref.read(formControllerProvider.notifier).handleEditForm(
                    globalKey: therapistProfileKey,
                    context: context,
                    actions: [
                      // TODO: UPDATE STUDIO HERE
                      () async => await ref.read(userControllerProvider.notifier).updateUserDocument(
                            name: nameController.text,
                            lastName: lastNameController.text,
                            email: emailController.text,
                            phoneNumber: phoneNumberController.text,
                            addressString: addressStringController.text,
                            studioName: studioNameController.text,
                            description: descriptionController.text,
                          ),
                    ],
                    onEnd: [
                      () => ref.read(userControllerProvider.notifier).syncCachedUserWithDatabase(),
                    ],
                  );
                },
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
