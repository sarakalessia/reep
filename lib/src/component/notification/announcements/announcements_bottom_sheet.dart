import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/input/input_field.dart';
import 'package:repathy/src/component/notification/announcements/announcements_patient_list.dart';
import 'package:repathy/src/controller/announcement_controller/announcement_controller.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/key/keys.dart';
import 'package:repathy/src/theme/styles.dart';

class AnnouncementsBottomSheet extends ConsumerStatefulWidget {
  const AnnouncementsBottomSheet({super.key, required this.patients});

  final List<UserModel> patients;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnnouncementsBottomSheetState();
}

class _AnnouncementsBottomSheetState extends ConsumerState<AnnouncementsBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    _titleFocusNode.addListener(setupListeners);
    _contentFocusNode.addListener(setupListeners);
    super.initState();
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void setupListeners() => ref.read(isPatientListOpenProvider.notifier).toggleState();

  @override
  Widget build(BuildContext context) {
    ref.watch(filteredPatientsForSelectionListProvider(widget.patients));
    final selectedPatients = ref.watch(selectedPatientsProvider(widget.patients));

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
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: RepathyStyle.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 8, 16),
            child: Text(
              'Nuova comunicazione',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: RepathyStyle.standardTextSize,
                fontWeight: RepathyStyle.standardFontWeight,
                color: RepathyStyle.defaultTextColor,
              ),
            ),
          ),
          Form(
            key: announcementKey,
            child: Column(
              children: [
                AnnouncementsPatientList(patients: widget.patients),
                InputFormField(
                    focusNode: _titleFocusNode,
                    controller: _titleController,
                    name: 'Titolo',
                    validator: (value) => ref.read(formControllerProvider.notifier).validateEmptyOrNull(value, context)),
                InputFormField(
                    focusNode: _contentFocusNode,
                    controller: _contentController,
                    name: 'Contenuto',
                    validator: (value) => ref.read(formControllerProvider.notifier).validateEmptyOrNull(value, context)),
                PrimaryButton(
                  text: 'Salva',
                  onPressed: () async {
                    ref.read(formControllerProvider.notifier).handleForm(
                      route: null,
                      globalKey: announcementKey,
                      context: context,
                      actions: [
                        () async {
                          final List<String> patientIdList = [];
                          for (final patient in selectedPatients) {
                            patientIdList.add(patient.id ?? '');
                          }
                          return await ref.read(announcementControllerProvider.notifier).sendAnnouncement(
                                receiverUserIds: patientIdList,
                                title: _titleController.text,
                                content: _contentController.text,
                              );
                        },
                      ],
                      onEnd: [
                        () async => await ref.refresh(getAnnouncementListProvider.future),
                        () => Navigator.of(context).pop(), // POP THE BOTTOM SHEET
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
