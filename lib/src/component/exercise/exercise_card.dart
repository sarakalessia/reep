import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/component/exercise/exercise_carousel.dart';
import 'package:repathy/src/component/exercise/new_exercise_text_field.dart';
import 'package:repathy/src/controller/exercise_controller/exercise_controller.dart';
import 'package:repathy/src/controller/exercise_list_controller/exercise_list_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/media_model_group/exercise_model/exercise_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class ExerciseCard extends ConsumerStatefulWidget {
  const ExerciseCard({
    super.key,
    this.isDetailsPage = false,
    this.exerciseModel,
    this.isPdf = false,
    this.index,
  });

  final bool isDetailsPage;
  final bool isPdf;
  final int? index; // USED IN PDFs BECAUSE IT'S WHERE YOU HAVE MULTIPLE EXERCISES
  final ExerciseModel? exerciseModel; // USED IN DETAILS/EDIT CONTEXT

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<ExerciseCard> {
  final TextEditingController exerciseTitleController = TextEditingController();
  final TextEditingController exerciseDescriptionController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  ExerciseModel? exercise;
  List<FocusNode> focusNodes = [];

  @override
  void initState() {
    super.initState();
    _updateExerciseFromModel();
    exerciseDescriptionController.text = exercise?.description ?? '';
    setsController.text = exercise?.sets?.toString() ?? '';
    repsController.text = exercise?.repetitions?.toString() ?? '';
    focusNodes = List.generate(4, (_) => FocusNode());
    _updateScroll();
  }

  @override
  void dispose() {
    exerciseTitleController.dispose();
    exerciseDescriptionController.dispose();
    setsController.dispose();
    repsController.dispose();
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    scrollController.dispose();
    super.dispose();
  }

  // TODO: THE APPROACH BELOW SHOULD BE SUBSTITUED BY THE USE OF PROVIDERS

  // This is used every time we need to update the exercise model
  void _updateExercise() {
    final exercise = ExerciseModel(
      description: exerciseDescriptionController.text,
      sets: int.tryParse(setsController.text),
      repetitions: int.tryParse(repsController.text),
    );
    debugPrint('View: ExerciseCard: updateExercise is updated with exercise: $exercise');
    if (widget.index == null) ref.read(exerciseControllerProvider.notifier).updateExerciseState(exercise);
  }

  void _updatePdfExercise() {
    final exerciseListController = ref.read(exerciseComponentListControllerProvider)[widget.index!];
    final exerciseModel = ExerciseModel(
      title: exerciseTitleController.text,
      description: exerciseDescriptionController.text,
      sets: int.tryParse(setsController.text),
      repetitions: int.tryParse(repsController.text),
    );
    final updatedExerciseComponent = exerciseListController.copyWith(exerciseModel: exerciseModel);
    debugPrint('View: ExerciseCard: updatePdfExercise is updated at index ${widget.index} with exercise: $exerciseModel');
    ref.read(exerciseComponentListControllerProvider.notifier).updateExerciseComponentState(updatedExerciseComponent, widget.index!);
  }

  // This is used when we're in an editing page, like the video details page
  void _updateExerciseFromModel() {
    if (widget.exerciseModel == null) return;
    exercise = ExerciseModel(
      description: widget.exerciseModel?.description,
      sets: widget.exerciseModel?.sets,
      repetitions: widget.exerciseModel?.repetitions,
      dueDate: widget.exerciseModel?.dueDate,
    );
  }

  void _updateScroll() {
    for (int i = 0; i < focusNodes.length; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus && (i == 2 || i == 3)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(Duration(milliseconds: 100), () {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          });
        }
        setState(() {});
      });
    }
  }

  void closeKeyboard() {
    for (var focusNode in focusNodes) {
      focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnyFieldFocused = focusNodes.any((focusNode) => focusNode.hasFocus);
    final UserModel? currentUser = ref.watch(userControllerProvider);
    final bool isReadOnly = currentUser?.role != RoleEnum.therapist;
    ref.watch(exerciseControllerProvider);

    return GestureDetector(
      onTap: () => closeKeyboard(),
      child: Card(
        color: RepathyStyle.lightBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
          height: widget.isPdf ? 340 : 200,
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                SizedBox(height: 12),
                if (widget.isPdf && widget.index != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 9,
                        child: ExerciseTextField(
                          hintText: AppLocalizations.of(context)!.exerciseTitle,
                          controller: exerciseTitleController,
                          onChanged: (value) => widget.isPdf ? _updatePdfExercise() : _updateExercise(),
                          focusNode: focusNodes[0],
                          isReadOnly: isReadOnly,
                          isDetailsPage: widget.isDetailsPage,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: () => ref.read(exerciseComponentListControllerProvider.notifier).removeExerciseComponentFromState(widget.index!),
                          icon: Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                  ExerciseCarousel(index: widget.index!)
                ],
                ExerciseTextField(
                  hintText: AppLocalizations.of(context)!.descriptionOptional,
                  controller: exerciseDescriptionController,
                  onChanged: (value) => widget.isPdf ? _updatePdfExercise() : _updateExercise(),
                  isMultiLine: true,
                  maxLength: 100,
                  focusNode: focusNodes[1],
                  width: 323,
                  isReadOnly: isReadOnly,
                  isDetailsPage: widget.isDetailsPage,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 32,
                      child: ExerciseTextField(
                        hintText: AppLocalizations.of(context)!.sets,
                        controller: setsController,
                        onChanged: (value) => widget.isPdf ? _updatePdfExercise() : _updateExercise(),
                        focusNode: focusNodes[2],
                        isReadOnly: isReadOnly,
                        isDetailsPage: widget.isDetailsPage,
                        isNumbersOnly: true,
                      ),
                    ),
                    SizedBox(width: 4),
                    Align(
                        alignment: Alignment.topCenter,
                        child: Text('x',
                            style: TextStyle(
                              color: RepathyStyle.darkTextColor,
                              fontSize: RepathyStyle.smallTextSize,
                            ))),
                    SizedBox(width: 4),
                    Expanded(
                      flex: 32,
                      child: ExerciseTextField(
                        hintText: AppLocalizations.of(context)!.repetitions,
                        controller: repsController,
                        onChanged: (value) => widget.isPdf ? _updatePdfExercise() : _updateExercise(),
                        focusNode: focusNodes[3],
                        isReadOnly: isReadOnly,
                        isDetailsPage: widget.isDetailsPage,
                        isNumbersOnly: true,
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
                if (isAnyFieldFocused) ...[
                  if (widget.isPdf && widget.isDetailsPage) ...[SizedBox(height: 250)],
                  if (widget.isPdf && !widget.isDetailsPage) ...[SizedBox(height: 130)],
                  if (!widget.isPdf && widget.isDetailsPage) ...[SizedBox(height: 160)],
                  if (!widget.isPdf && !widget.isDetailsPage) ...[SizedBox(height: 160)],
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
