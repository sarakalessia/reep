import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/current_text_controller/current_text_controller.dart';
import 'package:repathy/src/controller/pain_controller/pain_controller.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/repository/media_repository/media_repository.dart';
import 'package:repathy/src/util/enum/media_format_enum.dart';
import 'package:repathy/src/util/enum/pain_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_controller.g.dart';

@Riverpod(keepAlive: true)
class MediaController extends _$MediaController {
  @override
  MediaModel? build() => null;

  // STATE

  void updateState(MediaModel mediaModel) => state = mediaModel;

  // CREATE

  Future<ResultModel<MediaModel?>> saveMediaToFirestoreAndStorage(File? currentFile, MediaModel? media) async {
    if (currentFile == null || media == null) return ResultModel<MediaModel?>(error: 'No file or media model found');
    debugPrint('Controller: saveMediaToFirestoreAndStorage is called with media: $media and file: $currentFile');
    final userModel = ref.read(userControllerProvider);
    if (userModel == null) return ResultModel<MediaModel?>(error: 'No user found');
    final result = await ref.read(mediaRepositoryProvider.notifier).saveMediaToFirestore(media: media, file: currentFile, userModel: userModel);
    debugPrint('Controller: saveMediaToFirestoreAndStorage result is $result');
    updateState(result.data!);
    debugPrint('Controller: saveMediaToFirestoreAndStorage state after saving is is $state');
    return result;
  }

  // READ

  Future<ResultModel<List<MediaModel>>> getMediaListFromFirestore({
    UserModel? targetUser,
    MediaFormatEnum? mediaFormat,
    bool includeInteractions = false,
  }) async {
    final currentUser = ref.read(userControllerProvider);
    final result = await ref.read(mediaRepositoryProvider.notifier).getMediaListFromFirestore(
          currentUser: currentUser,
          targetUser: targetUser,
          mediaFormat: mediaFormat,
          includeInteractions: includeInteractions,
        );
    return result;
  }

  Future<ResultModel<File>> fetchMediaFile(String path) async {
    final result = await ref.read(mediaRepositoryProvider.notifier).fetchMediaFile(path);
    debugPrint('Controller: fetchMediaFile result is $result');
    return ResultModel(data: result.data);
  }

  Future<List<File>?> pickMultipleMediaFromGallery() async {
    final List<File>? result = await ref.read(mediaRepositoryProvider.notifier).pickMultipleMediaFromGallery();
    return result;
  }

  Future<File?> pickMediaFromGallery({required bool isVideo}) async {
    final File? result = await ref.read(mediaRepositoryProvider.notifier).pickMediaFromGallery(isVideo: isVideo);
    return result;
  }

  Future<List<File>?> captureMultipleMediaWithCamera() async {
    final List<File>? result = await ref.read(mediaRepositoryProvider.notifier).captureMultipleMediaWithCamera();
    return result;
  }

  Future<File?> captureMediaWithCamera({required bool isVideo}) async {
    final File? result = await ref.read(mediaRepositoryProvider.notifier).captureMediaWithCamera(isVideo: isVideo);
    return result;
  }

  // UPDATE

  Future<bool> linkMediaToPatients({
    required String mediaId,
    required List<String> patientIds,
  }) async {
    debugPrint('Controller: linkMediaToPatients is called with mediaId: $mediaId and patientIds: $patientIds');
    if (patientIds.isEmpty || mediaId.isEmpty) return false;
    await ref.read(mediaRepositoryProvider.notifier).linkMediaToPatients(mediaId: mediaId, patientIds: patientIds);
    return true;
  }

  Future<ResultModel<void>> toggleMediaVisibility({
    required String mediaId,
    required bool isCurrentlyPublic,
  }) async {
    ResultModel<void> result = await ref.read(mediaRepositoryProvider.notifier).toggleMediaVisibility(
          mediaId: mediaId,
          isCurrentlyPublic: isCurrentlyPublic,
        );
    return result;
  }

  // DELETE

  Future<ResultModel<void>> deleteMedia({
    required MediaModel media,
    required String therapistId,
  }) async {
    ResultModel<void> result = await ref.read(mediaRepositoryProvider.notifier).deleteMedia(
          media: media,
          therapistId: therapistId,
        );
    ref.read(userControllerProvider.notifier).syncCachedUserWithDatabase();    
    return result;
  }
}

// READ REACTIVELY

@Riverpod(keepAlive: true)
class MediaFormatFilter extends _$MediaFormatFilter {
  @override
  MediaFormatEnum build() => MediaFormatEnum.unknown;

  void updateMediaFormat(MediaFormatEnum mediaFormat) => state = mediaFormat;
  // void invalidateMediaFormat() => state = MediaFormatEnum.unknown;
}

@riverpod
FutureOr<ResultModel<File>> fetchMediaFile(Ref ref, String path) async {
  debugPrint('Controller: fetchMediaFile is called with path: $path');
  final result = await ref.read(mediaControllerProvider.notifier).fetchMediaFile(path);
  debugPrint('Controller: fetchMediaFile result is $result');
  return result;
}

@riverpod
FutureOr<ResultModel<List<MediaModel>>> getMediaList(
  Ref ref, {
  UserModel? targetUser,
  MediaFormatEnum? mediaFormat,
  bool includeInteractions = false,
}) async {
  return await ref.read(mediaControllerProvider.notifier).getMediaListFromFirestore(
        targetUser: targetUser,
        mediaFormat: mediaFormat,
        includeInteractions: includeInteractions,
      );
}

@riverpod
FutureOr<List<MediaModel>> filteredMediaList(Ref ref, {bool includeInteractions = false, UserModel? targetUser}) async {
  final String currentString = ref.watch(currentTextControllerProvider);
  final PainEnum currentPain = ref.watch(currentPainControllerProvider);
  final MediaFormatEnum currentMediaFormat = ref.watch(mediaFormatFilterProvider);
  final UserModel? currentPatient = ref.watch(currentPatientProvider);
  final result = await ref.read(getMediaListProvider(targetUser: targetUser, mediaFormat: null, includeInteractions: includeInteractions).future);
  final List<MediaModel>? resultList = result.data;
  final String? resultError = result.error;
  List<MediaModel> filteredMediaList = [];

  if (resultError != null || resultList == null || resultList.isEmpty) {
    debugPrint('Controller: filteredMediaList error is $resultError');
    return <MediaModel>[];
  } else {
    // FILTER BY TITLE AND PAIN
    filteredMediaList = resultList.where((MediaModel element) {
      final String? title = element.title;
      if (title == null) return currentString.isEmpty;

      final bool matchesTitle = title.toLowerCase().contains(currentString.toLowerCase());
      final bool matchesPain = currentPain == PainEnum.other || element.painEnum.contains(currentPain);

      return matchesTitle && matchesPain;
    }).toList();

    // FILTER BY PATIENT
    if (currentPatient != null) {
      filteredMediaList = filteredMediaList.where((MediaModel element) {
        final List<String> patientIds = element.patientIds;
        return patientIds.contains(currentPatient.id);
      }).toList();
    }

    // FILTER BY MEDIA TYPE (PDF OR ALL VIDEO TYPES)
    if (currentMediaFormat != MediaFormatEnum.unknown) {
      filteredMediaList = filteredMediaList.where((MediaModel element) {
        if (currentMediaFormat == MediaFormatEnum.pdf) {
          return element.mediaFormat == MediaFormatEnum.pdf;
        } else if (currentMediaFormat == MediaFormatEnum.mp4) {
          return element.mediaFormat == MediaFormatEnum.mp4 || element.mediaFormat == MediaFormatEnum.mov;
        } else {
          return element.mediaFormat == currentMediaFormat;
        }
      }).toList();
    }

    debugPrint('Controller: filteredMediaList filtered list length is ${filteredMediaList.length}');
    return filteredMediaList;
  }
}
