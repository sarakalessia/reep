import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/model/data_models/media_model_group/exercise_model/exercise_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'exercise_repository.g.dart';

@riverpod
class ExerciseRepository extends _$ExerciseRepository {
  @override
  void build() {}

  // CREATE

  Future<ResultModel<bool>> createExercisesAndLinkToMedia({
    required List<ExerciseModel> exercises,
    required String mediaId,
  }) async {
    debugPrint('Repository: createExercisesAndLinkToMedia is called with exercises: $exercises and mediaId: $mediaId');
    final mediaCollectionReference = ref.read(firestoreInstanceProvider).collection('media');
    final mediaDocumentReference = mediaCollectionReference.doc(mediaId);
    final exerciseCollectionReference = mediaDocumentReference.collection('exercise');
    final exerciseDocumentReferences = [];

    try {
      for (final exercise in exercises) {
        final ExerciseModel newExercise = exercise.copyWith(mediaId: mediaId, createdAt: DateTime.now());
        final newDocumentReference = await exerciseCollectionReference.add(newExercise.toJson());
        await newDocumentReference.set({'id': newDocumentReference.id}, SetOptions(merge: true));
        exerciseDocumentReferences.add(newDocumentReference);
      }
      debugPrint('Repository: createExercisesAndLinkToMedia exerciseDocumentReferences is $exerciseDocumentReferences');
      return ResultModel(data: true);
    } catch (e) {
      debugPrint('Repository: createExercisesAndLinkToMedia error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // READ

  Future<ResultModel<List<ExerciseModel>>> getExercisesByMediaId({required String mediaId}) async {
    debugPrint('Repository: getExercisesByMediaId is called with mediaId: $mediaId');
    final mediaCollectionReference = ref.read(firestoreInstanceProvider).collection('media');
    final mediaDocumentReference = mediaCollectionReference.doc(mediaId);
    final exerciseCollectionReference = mediaDocumentReference.collection('exercise');

    try {
      final querySnapshot = await exerciseCollectionReference.get();
      final exercise = querySnapshot.docs.map((doc) => ExerciseModel.fromJson(doc.data())).toList();
      debugPrint('Repository: getExercisesByMediaId exercises is $exercise');
      return ResultModel(data: exercise);
    } catch (e) {
      debugPrint('Repository: getExercisesByMediaId error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // UPDATE

  Future<ResultModel<bool>> updateExercise({required ExerciseModel exercise}) async {
    debugPrint('Repository: updateExercise is called with exercise: $exercise');
    final mediaCollectionReference = ref.read(firestoreInstanceProvider).collection('media');
    final mediaDocumentReference = mediaCollectionReference.doc(exercise.mediaId!);
    final exerciseCollectionReference = mediaDocumentReference.collection('exercise');
    final exerciseDocumentReference = exerciseCollectionReference.doc(exercise.id);

    try {
      await exerciseDocumentReference.set(exercise.toJson(), SetOptions(merge: true));
      debugPrint('Repository: updateExercise exercise is $exercise');
      return ResultModel(data: true);
    } catch (e) {
      debugPrint('Repository: updateExercise error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // DELETE

  Future<ResultModel<bool>> deleteExercise({required ExerciseModel exercise}) async {
    debugPrint('Repository: deleteExercise is called with exercise: $exercise');
    final mediaCollectionReference = ref.read(firestoreInstanceProvider).collection('media');
    final mediaDocumentReference = mediaCollectionReference.doc(exercise.mediaId!);
    final exerciseCollectionReference = mediaDocumentReference.collection('exercise');
    final exerciseDocumentReference = exerciseCollectionReference.doc(exercise.id);

    try {
      await exerciseDocumentReference.delete();
      debugPrint('Repository: deleteExercise exercise is $exercise');
      return ResultModel(data: true);
    } catch (e) {
      debugPrint('Repository: deleteExercise error is $e');
      return ResultModel(error: e.toString());
    }
  }
}
