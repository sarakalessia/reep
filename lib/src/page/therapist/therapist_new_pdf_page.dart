import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/button/secondary_button.dart';
import 'package:repathy/src/component/exercise/exercise_card.dart';
import 'package:repathy/src/component/media/media_title.dart';
import 'package:repathy/src/component/pain/pain_avatar_carrousel.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/exercise_list_controller/exercise_list_controller.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/controller/pain_controller/pain_controller.dart';
import 'package:repathy/src/model/component_models/exercise_component_model/exercise_component_model.dart';
import 'package:repathy/src/model/component_models/pain_component_model/pain_component_model.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/util/enum/element_size_enum.dart';
import 'package:repathy/src/util/enum/media_format_enum.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/util/helper/snackbar/snackbar.dart';

class TherapistNewPdfPage extends ConsumerStatefulWidget {
  const TherapistNewPdfPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TherapistNewPdfPageState();
}

class _TherapistNewPdfPageState extends ConsumerState<TherapistNewPdfPage> {
  final mediaTitleController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    mediaTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ExerciseComponentModel> exerciseListController = ref.watch(exerciseComponentListControllerProvider);
    final List<PainComponentModel> painList = ref.watch(painControllerProvider);
    ref.watch(mediaControllerProvider);

    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
              child: MediaTitle(textEditingController: mediaTitleController, isVideo: false),
            ),
            PainAvatarCarrousel(),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              height: 350,
              child: ListView.builder(
                controller: scrollController,
                itemBuilder: (context, index) => ExerciseCard(index: index, isPdf: true),
                itemCount: exerciseListController.length,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SecodaryButton(
                  isRounded: true,
                  size: ElementSize.mini,
                  text: '+ Esercizi',
                  onPressed: () {
                    ref.read(exerciseComponentListControllerProvider.notifier).addExerciseComponentToState(ExerciseComponentModel());
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final targetScrollPosition = scrollController.position.maxScrollExtent * 0.95;
                      scrollController.animateTo(
                        targetScrollPosition,
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    });
                  },
                ),
                PrimaryButton(
                    isRounded: true,
                    size: ElementSize.mini,
                    text: 'Avanti',
                    onPressed: () async {
                      // PUT THE BUTTON TO LOADING STATE
                      ref.read(formControllerProvider.notifier).setStateToFalse();

                      // APPLY SEVERAL BUSINESS RULES TO CHECK IF WE CAN MOVE TO THE PREVIEW PAGE
                      if (painList.every((element) => !element.isSelected)) {
                        ref.read(formControllerProvider.notifier).setStateToTrue();
                        return await ref.read(snackBarProvider(text: 'Seleziona almeno un dolore').future);
                      }

                      if (exerciseListController.isEmpty) {
                        ref.read(formControllerProvider.notifier).setStateToTrue();
                        return await ref.read(snackBarProvider(text: 'Aggiungi almeno un esercizio').future);
                      }

                      if (exerciseListController.any((exercise) => exercise.images.isEmpty)) {
                        ref.read(formControllerProvider.notifier).setStateToTrue();
                        return await ref.read(snackBarProvider(text: 'Ogni esercizio deve avere almeno una foto').future);
                      }

                      if (exerciseListController.any((exercise) =>
                          exercise.exerciseModel == null ||
                          exercise.exerciseModel!.title == null ||
                          exercise.exerciseModel!.title!.isEmpty ||
                          exercise.exerciseModel!.sets == null ||
                          exercise.exerciseModel!.repetitions == null)) {
                        ref.read(formControllerProvider.notifier).setStateToTrue();
                        debugPrint('View: TherapistNewPdfPage: exerciseListController: $exerciseListController');
                        return await ref.read(snackBarProvider(text: 'Ogni esercizio deve avere titolo, serie e ripetizioni').future);
                      }

                      // UPDATE THE MEDIA CONTROLLER WITH APPRPRIATE DATA
                      final painEnumList = ref.read(painControllerProvider.notifier).exctractPainEnumListFromState();
                      final updatedMedia = MediaModel(mediaFormat: MediaFormatEnum.pdf, painEnum: painEnumList, title: mediaTitleController.text);
                      ref.read(mediaControllerProvider.notifier).updateState(updatedMedia);

                      // REMOVE THE LOADING STATE BEFORE NAVIGATING
                      ref.read(formControllerProvider.notifier).setStateToTrue();

                      // NAVIGATE
                      ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 0, subPage: PageEnum.pdfPreview);
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
