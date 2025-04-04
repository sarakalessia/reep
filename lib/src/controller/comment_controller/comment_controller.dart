import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/model/data_models/comment_model/comment_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/repository/comment_repository/comment_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'comment_controller.g.dart';

@Riverpod(keepAlive: true)
class CommentController extends _$CommentController {
  @override
  List<CommentModel> build() => [];

  // STATE
  updateState(List<CommentModel> comments) => state = comments;

  // CREATE
  Future<ResultModel<CommentModel>> createComment({required MediaModel mediaModel, required String content}) async {
    debugPrint('Controller: createComment is called with content: $content');
    final currentUser = ref.read(userControllerProvider);
    if (currentUser == null) return ResultModel(error: 'Utente non trovato');
    final result = await ref.read(commentRepositoryProvider.notifier).commentOnMedia(
          mediaModel: mediaModel,
          content: content,
          currentUser: currentUser,
        );
    return result;
  }
}

// READ REACTIVELY

@riverpod
FutureOr<ResultModel<List<CommentModel>>> getComments(Ref ref) async {
  final currentUser = ref.read(userControllerProvider);
  final currentMedia = ref.watch(mediaControllerProvider);
  if (currentUser == null) return ResultModel(error: 'Utente non trovato');
  final result = await ref.read(commentRepositoryProvider.notifier).getComments(
        currentUser: currentUser,
        mediaModel: currentMedia,
      );
  debugPrint('Controller: getComments result is $result');    
  return result;
}
