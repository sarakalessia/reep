import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/exercise/new_exercise.dart';
import 'package:repathy/src/component/media/media_title.dart';
import 'package:repathy/src/component/pain/pain_avatar_carrousel.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/exercise_controller/exercise_controller.dart';
import 'package:repathy/src/controller/file_controller/file_controller.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/controller/pain_controller/pain_controller.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/model/data_models/media_model_group/exercise_model/exercise_model.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/model/component_models/pain_component_model/pain_component_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/media_format_enum.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/util/enum/pain_enum.dart';
import 'package:repathy/src/util/helper/snackbar/snackbar.dart';

class TherapistNewVideoPage extends ConsumerStatefulWidget {
  const TherapistNewVideoPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TherapistNewVideoPageState();
}

class _TherapistNewVideoPageState extends ConsumerState<TherapistNewVideoPage> {
  final mediaTitleController = TextEditingController();

  @override
  void dispose() {
    mediaTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final File? file = ref.watch(currentFileControllerProvider);
    final List<PainComponentModel> painList = ref.watch(painControllerProvider);
    final MediaModel? currentMedia = ref.watch(mediaControllerProvider);
    final ExerciseModel? exercise = ref.watch(exerciseControllerProvider);
    final UserModel? currentPatient = ref.watch(currentPatientProvider);

    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 100,
                    child: MediaTitle(textEditingController: mediaTitleController, isVideo: true),
                  ),
                ],
              ),
            ),
            PainAvatarCarrousel(),
            NewExercise(),
            SizedBox(height: 70),
            PrimaryButton(
              text: 'Avanti',
              onPressed: () async {
                // PUT THE BUTTON TO LOADING STATE
                ref.read(formControllerProvider.notifier).setStateToFalse();

                // APPLY SEVERAL BUSINESS RULES TO CHECK IF WE CAN CREATE THE MEDIA
                if (file == null) {
                  ref.read(formControllerProvider.notifier).setStateToTrue();
                  return await ref.read(snackBarProvider(text: 'Per favore rifare il video').future);
                }
                if (painList.every((element) => !element.isSelected)) {
                  ref.read(formControllerProvider.notifier).setStateToTrue();
                  return await ref.read(snackBarProvider(text: 'Seleziona almeno un dolore').future);
                }
                if (exercise == null) {
                  ref.read(formControllerProvider.notifier).setStateToTrue();
                  return await ref.read(snackBarProvider(text: 'Aggiungi almeno un esercizio').future);
                }

                if (exercise.sets == null || exercise.repetitions == null) {
                  ref.read(formControllerProvider.notifier).setStateToTrue();
                  return await ref.read(snackBarProvider(text: 'Compila i campi obbligatori').future);
                }

                // IF WE ARRIVE HERE WE CAN CREATE THE MEDIA
                final List<PainEnum> painEnumList = ref.read(painControllerProvider.notifier).exctractPainEnumListFromState();
                debugPrint('View: PainEnumList: $painEnumList');
                final MediaFormatEnum mediaFormat = ref.read(currentFileControllerProvider.notifier).getMediaFormat();
                debugPrint('View: MediaFormat: $mediaFormat');
                MediaModel? updatedMedia = MediaModel(mediaFormat: mediaFormat, painEnum: painEnumList, title: mediaTitleController.text);
                debugPrint('View: UpdatedMedia: $updatedMedia');
                ref.read(mediaControllerProvider.notifier).updateState(updatedMedia);
                debugPrint('View: CurrentMedia: $currentMedia');
                final createdMedia = await ref.read(mediaControllerProvider.notifier).saveMediaToFirestoreAndStorage(file, updatedMedia);
                if (createdMedia.error != null) {
                  ref.read(formControllerProvider.notifier).setStateToTrue();
                  return await ref.read(snackBarProvider(text: 'Errore durante il caricamento del video').future);
                }
                debugPrint('View: CreatedMedia: $createdMedia');
                ref.read(mediaControllerProvider.notifier).updateState(createdMedia.data!);
                final result = await ref.read(exerciseControllerProvider.notifier).createExerciseAndLinkToMedia(mediaId: createdMedia.data!.id);
                if (result.error != null) {
                  ref.read(formControllerProvider.notifier).setStateToTrue();
                  return await ref.read(snackBarProvider(text: 'Errore durante il caricamento degli esercizi').future);
                }
                // ALL OPERATIONS ARE FINISHED, CANCEL ALL PROVIDERS AND NAVIGATE TO THE NEXT PAGE
                ref.invalidate(painControllerProvider);
                ref.invalidate(exerciseControllerProvider);

                // REMOVE THE LOADING STATE BEFORE NAVIGATING
                ref.read(formControllerProvider.notifier).setStateToTrue();

                if (currentPatient == null) {
                  ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 3, subPage: PageEnum.linkMediaToPatient);
                  return;
                }

                ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 0, subPage: PageEnum.patientDetail);

                if (context.mounted) ref.read(snackBarProvider(text: 'Video creato con successo!', successOrFail: true).future);
              },
            ),
          ],
        ),
      ),
    );
  }
}
