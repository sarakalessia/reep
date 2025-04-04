import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/controller/therapist_controller/therapist_controller.dart';
import 'package:repathy/src/controller/transfer_controller/transfer_controller.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/component/patient_transfer/patient_transfer_card.dart';
import 'package:repathy/src/util/key/keys.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/util/helper/snackbar/snackbar.dart';

class PatientTransferPage extends ConsumerStatefulWidget {
  const PatientTransferPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PatientListPageState();
}

class _PatientListPageState extends ConsumerState<PatientTransferPage> {
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncFilteredPatients = ref.watch(asyncFilteredPatientsProvider(excludeTransferedPatients: true));
    final asyncFilteredTherapists = ref.watch(asyncFilteredTherapistsProvider(removeMyself: true));

    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Align(alignment: Alignment.centerLeft, child: PageTitleText(title: 'Trasferisci')),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Align(alignment: Alignment.centerLeft, child: PageDescriptionText(title: 'Trasferisci i tuoi pazienti ad un tuo collega')),
            ),
            asyncFilteredPatients.when(
              data: (ResultModel<List<UserModel>> data) {
                final filteredPatientsResult = data.data;
                debugPrint('View: filteredPatientsResult: ${filteredPatientsResult?.length}');
                if (filteredPatientsResult == null || filteredPatientsResult.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                    child: Center(child: Text('Nessun paziente trovato')),
                  );
                }
                return PatientTransferCard(
                  step: 1,
                  title: 'Pazienti',
                  description: 'Elenco dei tuoi pazienti',
                  topPadding: 24,
                  elements: filteredPatientsResult,
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Nessun paziente trovato')),
            ),
            asyncFilteredTherapists.when(
              data: (ResultModel<List<UserModel>> data) {
                final filteredTherapistsResult = data.data;
                debugPrint('View: filteredTherapistsResult: ${filteredTherapistsResult?.length}');
                if (filteredTherapistsResult == null || filteredTherapistsResult.isEmpty) return Center(child: Text('Nessun terapista trovato'));
                return PatientTransferCard(
                  step: 2,
                  title: 'Fisioterapisti',
                  description: 'Elenco dei terapisti a cui trasferire i tuoi pazienti',
                  internalTopPadding: 22,
                  elements: filteredTherapistsResult,
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Nessun terapista trovato')),
            ),
            Form(
              key: patientTransferKey,
              child: PatientTransferCard(
                step: 3,
                title: 'Commento',
                description: 'Lascia un commento',
                bottomPadding: 16,
                textController: descriptionController,
                extendedHeight: 250,
              ),
            ),
            SizedBox(height: 64),
            PrimaryButton(
              bottomPadding: 32,
              text: 'Trasferisci',
              onPressed: () async {
                final List<UserModel> filteredPatientsResult = ref.read(syncFilteredPatientsProvider);
                final List<UserModel> filteredTherapistsResult = ref.read(syncFilteredTherapistsProvider);
                final List<UserModel> selectedPatients = ref.read(selectedPatientsProvider(filteredPatientsResult));
                final List<UserModel> selectedTherapists = ref.read(selectedPatientsProvider(filteredTherapistsResult));

                debugPrint(
                  'View: '
                  'filteredPatientsResult: ${filteredPatientsResult.length},'
                  'filteredTherapistsResult: ${filteredTherapistsResult.length},'
                  'selectedPatients: ${selectedPatients.length}, and id ${selectedPatients.first.id},'
                  'selectedTherapists: ${selectedTherapists.length}, and id ${selectedTherapists.first.id},'
                  'description: ${descriptionController.text}',
                );

                if (selectedPatients.isEmpty || selectedTherapists.isEmpty) {
                  ref.read(snackBarProvider(text: 'Seleziona almeno un paziente e un terapista'));
                  return;
                }

                await ref.read(formControllerProvider.notifier).handleForm(
                  globalKey: patientTransferKey,
                  context: context,
                  actions: [
                    () async => await ref.read(transferControllerProvider.notifier).sendTransferRequest(
                          patientId: selectedPatients.first.id!,
                          substituteTherapistId: selectedTherapists.first.id!,
                          content: descriptionController.text,
                        ),
                  ],
                  onEnd: [
                    () => ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 0, subPage: PageEnum.none),
                    () => ref.read(snackBarProvider(text: 'Richiesta di trasferimento inviata', successOrFail: true)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
