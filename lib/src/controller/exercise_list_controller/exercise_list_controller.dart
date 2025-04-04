import 'dart:io';
import 'package:repathy/src/model/component_models/exercise_component_model/exercise_component_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exercise_list_controller.g.dart';

@Riverpod(keepAlive: true)
class ExerciseComponentListController extends _$ExerciseComponentListController {
  @override
  List<ExerciseComponentModel> build() {
    return <ExerciseComponentModel>[
      ExerciseComponentModel(),
    ];
  }

  void addExerciseComponentToState(ExerciseComponentModel exerciseComponent) {
    state = [...state, exerciseComponent];
  }

  void addFileListToExerciseComponentState(int index, List<File> files) {
    final newState = List<ExerciseComponentModel>.from(state);
    final updatedExerciseComponent = newState[index].copyWith(
      images: [...newState[index].images, ...files],
    );
    newState[index] = updatedExerciseComponent;
    state = newState;
  }

  void updateExerciseComponentState(ExerciseComponentModel exerciseComponent, int index) {
    final newState = List<ExerciseComponentModel>.from(state);
    newState[index] = exerciseComponent;
    state = newState;
  }

  void removeExerciseComponentFromState(int index) {
    final newState = List<ExerciseComponentModel>.from(state);
    newState.removeAt(index);
    state = newState;
  }

  void removeFileFromExerciseComponentState(int index, File file) {
    final newState = List<ExerciseComponentModel>.from(state);
    final updatedExerciseComponent = newState[index].copyWith(
      images: newState[index].images.where((f) => f != file).toList(),
    );
    newState[index] = updatedExerciseComponent;
    state = newState;
  }
}
