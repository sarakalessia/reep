import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/exercise_list_controller/exercise_list_controller.dart';
import 'package:repathy/src/model/component_models/exercise_component_model/exercise_component_model.dart';
import 'package:repathy/src/model/data_models/media_model_group/exercise_model/exercise_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/repository/exercise_repository/exercise_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exercise_controller.g.dart';

// THIS IS USED FOR VIDEOS, WHERE WE WORK AROUND A SINGLE EXERCISE

@Riverpod(keepAlive: true)
class ExerciseController extends _$ExerciseController {
  @override
  ExerciseModel? build() => null;

  // STATE

  void updateExerciseState(ExerciseModel exercise) => state = exercise;
  void removeExercise() => state = null;

  // CREATE

  Future<ResultModel<bool>> createExerciseAndLinkToMedia({required mediaId}) async {
    debugPrint('Controller: createExerciseAndLinkToMedia is called with mediaId: $mediaId');
    if (state == null) return ResultModel(error: 'No exercise found');
    final result = await ref.read(exerciseRepositoryProvider.notifier).createExercisesAndLinkToMedia(exercises: [state!], mediaId: mediaId);
    return result;
  }

  Future<ResultModel<bool>> createExerciseListAndLinkToMedia({required String mediaId}) async {
    debugPrint('Controller: createExerciseListAndLinkToMedia is called with mediaId: $mediaId');
    final List<ExerciseComponentModel> exerciseComponentList = ref.read(exerciseComponentListControllerProvider);
    if (exerciseComponentList.isEmpty) return ResultModel(error: 'No exercises found');

    final List<ExerciseModel> exerciseList = exerciseComponentList.where((e) => e.exerciseModel != null).map((e) => e.exerciseModel!).toList();

    if (exerciseList.isEmpty) return ResultModel(error: 'Some exercises are null');

    final result = await ref.read(exerciseRepositoryProvider.notifier).createExercisesAndLinkToMedia(exercises: exerciseList, mediaId: mediaId);

    return result;
  }

  // READ

  Future<ResultModel<List<ExerciseModel>>> getExercisesByMediaId({required String? mediaId}) async {
    if (mediaId == null) return ResultModel(error: 'No mediaId found');
    final result = await ref.read(exerciseRepositoryProvider.notifier).getExercisesByMediaId(mediaId: mediaId);
    return result;
  }

  // UPDATE

  Future<ResultModel<bool>> updateExercise({
    required ExerciseModel exercise,
  }) async {
    ResultModel<bool> result = await ref.read(exerciseRepositoryProvider.notifier).updateExercise(exercise: exercise);
    return result;
  }

  // DELETE

  Future<ResultModel<bool>> deleteExercise({
    required ExerciseModel exercise,
  }) async {
    ResultModel<bool> result = await ref.read(exerciseRepositoryProvider.notifier).deleteExercise(exercise: exercise);
    return result;
  }
}

// READ REACTIVELY

@riverpod
FutureOr<ResultModel<List<ExerciseModel>>> getExercisesByMediaId(Ref ref, String? mediaId) async {
  debugPrint('Controller: getExercisesByMediaId is called with mediaId: $mediaId');
  if (mediaId == null) return ResultModel(error: 'No mediaId found');
  final result = await ref.read(exerciseRepositoryProvider.notifier).getExercisesByMediaId(mediaId: mediaId);
  debugPrint('Controller: getExercisesByMediaId result is $result');
  return result;
}
