import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_model.freezed.dart';
part 'exercise_model.g.dart';

@freezed
abstract class ExerciseModel with _$ExerciseModel {
  const factory ExerciseModel({
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? dueDate,
    String? id,
    String? mediaId,
    String? title, 
    String? description,
    int? repetitions, // For PDFs this is relegated to each exercise
    int? sets, // For PDFs this is relegated to each exercise
    @Default([]) List<String> imagePaths,
  }) = _ExerciseModel;

  factory ExerciseModel.fromJson(Map<String, Object?> json) => _$ExerciseModelFromJson(json);
}