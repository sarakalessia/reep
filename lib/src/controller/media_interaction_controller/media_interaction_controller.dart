import 'package:flutter/material.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_interaction_model/media_interaction_model.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/repository/media_repository/media_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_interaction_controller.g.dart';

@riverpod
class MediaInteractionController extends _$MediaInteractionController {
  @override
  List<MediaInteractionModel> build() => <MediaInteractionModel>[];

  // STATE

  List<MediaInteractionModel> getAllInteractionsFromAMediaList(List<MediaModel>? mediaModelList) {
    if (mediaModelList == null) return <MediaInteractionModel>[];
    final List<MediaInteractionModel> mediaInteractionList = <MediaInteractionModel>[];
    for (final mediaModel in mediaModelList) {
      if (mediaModel.mediaInteractions.isNotEmpty) {
        mediaInteractionList.addAll(mediaModel.mediaInteractions);
      }
    }
    return mediaInteractionList;
  }

  MediaInteractionModel? findClosestInteraction(List<MediaInteractionModel> mediaInteractionList) {
    if (mediaInteractionList.isEmpty) return null;
    final now = DateTime.now();
    return mediaInteractionList.reduce((a, b) {
      final aOpenedAt = a.openedAt;
      final bOpenedAt = b.openedAt;
      if (aOpenedAt == null || bOpenedAt == null) return aOpenedAt != null ? a : b;
      return (aOpenedAt.difference(now).abs() < bOpenedAt.difference(now).abs()) ? a : b;
    });
  }

  MediaModel? findMediaModelById(List<MediaModel>? mediaModelList, String? mediaId) {
    if (mediaModelList == null || mediaId == null) return null;
    return mediaModelList.firstWhere((mediaModel) => mediaModel.id == mediaId, orElse: () => MediaModel());
  }

  // CREATE
  Future<ResultModel<MediaInteractionModel?>> saveMediaInteractionToFirestore(MediaModel mediaModel) async {
    debugPrint('View: about to save the first interaction with video ${mediaModel.id}');
    final userModel = ref.read(userControllerProvider);
    if (userModel == null) return ResultModel<MediaInteractionModel?>(error: 'No user found');
    final result = await ref.read(mediaRepositoryProvider.notifier).saveMediaInteractionToFirestore(mediaModel, userModel);
    return result;
  }

  // UPDATE
  Future<ResultModel<MediaInteractionModel?>> updateMediaInteraction(MediaInteractionModel mediaInteractionModel, String mediaId) async {
    final userModel = ref.read(userControllerProvider);
    if (userModel == null) return ResultModel<MediaInteractionModel?>(error: 'No user found');
    final result = await ref.read(mediaRepositoryProvider.notifier).updateMediaInteraction(mediaInteractionModel, mediaId);
    return result;
  }
}
