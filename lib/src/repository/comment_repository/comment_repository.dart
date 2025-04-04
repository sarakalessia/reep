import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/model/data_models/comment_model/comment_model.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'comment_repository.g.dart';

@riverpod
class CommentRepository extends _$CommentRepository {
  @override
  void build() {}

  // CREATE

  Future<ResultModel<CommentModel>> commentOnMedia({required MediaModel mediaModel, required String content, required UserModel currentUser}) async {
    debugPrint('Repository: commentOnMedia is called with ${mediaModel.id}, $content, ${currentUser.id}');
    final Map<String, dynamic> commentMap;
    final DocumentReference<Map<String, dynamic>> documentReference;
    final DocumentSnapshot<Map<String, dynamic>> newDocumentSnapshot;
    final Map<String, dynamic>? newDocumentMap;
    CommentModel? newComment;

    try {
      newComment = CommentModel(
        authorId: currentUser.id,
        mediaId: mediaModel.id,
        content: content,
        createdAt: DateTime.now(),
      );

      commentMap = newComment.toJson();
      documentReference = await ref.read(firestoreInstanceProvider).collection('media').doc(mediaModel.id).collection('comments').add(commentMap);
      await documentReference.set({'id': documentReference.id}, SetOptions(merge: true));
      newDocumentSnapshot = await documentReference.get();
      newDocumentMap = newDocumentSnapshot.data();
      if (newDocumentMap == null) return ResultModel(error: 'comment-not-found');
      newComment = CommentModel.fromJson(newDocumentMap);

      debugPrint('Repository: commentOnMedia newComment before returning is $newComment');
      return ResultModel(data: newComment);
    } catch (e) {
      debugPrint('Repository: commentOnMedia error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // READ

  Future<ResultModel<List<CommentModel>>> getComments({
    MediaModel? mediaModel,
    required UserModel currentUser,
  }) async {
    debugPrint('Repository: getComments is called with mediaModel: ${mediaModel?.id}, currentUser: ${currentUser.id}');
    final List<CommentModel> commentModelList = [];
    final QuerySnapshot<Map<String, dynamic>> querySnapshot;
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> queryDocuments;
    final Query<Map<String, dynamic>> query;

    try {
      if (mediaModel != null) {
        debugPrint('Repository: getComments mediaModel is ${mediaModel.id}'); 
        final collectionReference = ref.read(firestoreInstanceProvider).collection('media').doc(mediaModel.id).collection('comments');
        query = collectionReference;
      } else {
        debugPrint('Repository: getComments mediaModel is null');
        final collectionReference = ref.read(firestoreInstanceProvider).collectionGroup('comments');
        if (currentUser.role == RoleEnum.therapist) {
          debugPrint('Repository: getComments currentUser is a therapist case');
          final List<String> mediaIds = currentUser.mediaIdList;
          query = collectionReference.where('mediaId', whereIn: mediaIds);
        } else {
          debugPrint('Repository: getComments currentUser is a patient case');
          query = collectionReference.where('authorId', isEqualTo: currentUser.id);
        }
      }

      querySnapshot = await query.get();
      queryDocuments = querySnapshot.docs;

      debugPrint('Repository: getComments queryDocuments length is ${queryDocuments.length}');

      if (queryDocuments.isEmpty) return ResultModel(error: 'comment-list-empty');

      debugPrint('Repository: getComments length is ${queryDocuments.length}');

      for (final queryDocument in queryDocuments) {
        final commentModel = CommentModel.fromJson(queryDocument.data());
        commentModelList.add(commentModel);
      }

      debugPrint('Repository: getComments length before returning is ${commentModelList.length}');
      return ResultModel(data: commentModelList);
    } catch (e) {
      debugPrint('Repository: getComments error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // UPDATE

  Future<ResultModel<CommentModel>> markCommentAsRead({required CommentModel commentModel, required UserModel currentUser}) async {
    debugPrint('Repository: markCommentAsRead is called with ${commentModel.id}, ${currentUser.id}');
    final DocumentReference<Map<String, dynamic>> documentReference;
    final Map<String, dynamic> commentMap;
    final DocumentSnapshot<Map<String, dynamic>> newDocumentSnapshot;
    final Map<String, dynamic>? newDocumentMap;
    CommentModel? newComment;

    try {
      documentReference = ref.read(firestoreInstanceProvider).collection('comments').doc(commentModel.id);
      newComment = commentModel.copyWith(readAt: DateTime.now());
      commentMap = newComment.toJson();
      await documentReference.set(commentMap, SetOptions(merge: true));
      newDocumentSnapshot = await documentReference.get();
      newDocumentMap = newDocumentSnapshot.data();
      if (newDocumentMap == null) return ResultModel(error: 'comment-not-found');
      newComment = CommentModel.fromJson(newDocumentMap);
      debugPrint('Repository: markCommentAsRead newComment before returning is $newComment');
      return ResultModel(data: newComment);
    } catch (e) {
      debugPrint('Repository: markCommentAsRead error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // DELETE

  deleteCommentByCommentId(String commentId) async {
    debugPrint('Repository: deleteCommentByCommentId is called with $commentId');
    try {
      await ref.read(firestoreInstanceProvider).collection('comments').doc(commentId).delete();
    } catch (e) {
      debugPrint('Repository: deleteCommentByCommentId error is $e');
    }
  }
}
