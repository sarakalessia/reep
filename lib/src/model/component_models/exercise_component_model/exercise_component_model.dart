import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repathy/src/model/data_models/media_model_group/exercise_model/exercise_model.dart';

part 'exercise_component_model.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class ExerciseComponentModel with _$ExerciseComponentModel {
  const factory ExerciseComponentModel({
    ExerciseModel? exerciseModel,
    @Default(<File>[]) List<File> images,
  }) = _ExerciseComponentModel;
}
