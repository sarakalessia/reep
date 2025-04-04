import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/model/data_models/announcement_model/announcement_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'announcements_repository.g.dart';

@riverpod
class AnnouncementRepository extends _$AnnouncementRepository {
  @override
  void build() {}

  // CREATE

  Future<ResultModel<AnnouncementModel>> sendAnnouncement({
    required List<String> receiverUserIds,
    required String content,
    required String title,
    required UserModel currentUser,
  }) async {
    debugPrint('Repository: sendAnnouncement is called with receiverUserIds: $receiverUserIds, content: $content, title: $title');
    final Map<String, dynamic> announcementMap;
    final DocumentReference<Map<String, dynamic>> documentReference;
    final DocumentReference<Map<String, dynamic>> userDocReference;
    final DocumentSnapshot<Map<String, dynamic>> newDocumentSnapshot;
    final Map<String, dynamic>? newDocumentMap;
    AnnouncementModel? newMessage;

    try {
      // Create new announcement
      newMessage = AnnouncementModel(
        senderId: currentUser.id,
        receiverIds: receiverUserIds,
        sentAt: DateTime.now(),
        content: content,
        title: title,
      );

      announcementMap = newMessage.toJson();
      documentReference = await ref.read(firestoreInstanceProvider).collection('announcements').add(announcementMap);
      userDocReference = ref.read(firestoreInstanceProvider).collection('user').doc(currentUser.id);

      // Announcement the announcement with the generated ID
      await documentReference.set({'id': documentReference.id}, SetOptions(merge: true));
      await userDocReference.set({
        'announcementIdList': FieldValue.arrayUnion([documentReference.id])
      }, SetOptions(merge: true));

      // Fetch the updated document
      newDocumentSnapshot = await documentReference.get();
      newDocumentMap = newDocumentSnapshot.data();
      if (newDocumentMap == null) return ResultModel(error: 'announcement-not-found');

      // Announcement the newMessage object with the correct ID
      newMessage = AnnouncementModel.fromJson(newDocumentMap);

      return ResultModel(data: newMessage);
    } catch (e) {
      debugPrint('Repository: sendAnnouncement error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // READ

  Future<ResultModel<List<AnnouncementModel>>> getAnnouncementList(UserModel currentUser) async {
    debugPrint('Repository: getAnnouncement is called');
    final collectionReference = ref.read(firestoreInstanceProvider).collection('announcements');
    final List<AnnouncementModel> updatesModels = [];

    try {
      // Query for receiverIds
      final receiverQuery = collectionReference.where('receiverIds', arrayContains: currentUser.id).orderBy('sentAt', descending: true);
      final receiverQuerySnapshot = await receiverQuery.get();
      final receiverQueryDocuments = receiverQuerySnapshot.docs;

      // Query for senderId
      final senderQuery = collectionReference.where('senderId', isEqualTo: currentUser.id).orderBy('sentAt', descending: true);
      final senderQuerySnapshot = await senderQuery.get();
      final senderQueryDocuments = senderQuerySnapshot.docs;

      // Combine results
      final Set<String> processedIds = {};
      for (final queryDocument in receiverQueryDocuments) {
        final updatesModel = AnnouncementModel.fromJson(queryDocument.data());
        updatesModels.add(updatesModel);
        processedIds.add(queryDocument.id);
      }
      for (final queryDocument in senderQueryDocuments) {
        if (!processedIds.contains(queryDocument.id)) {
          final updatesModel = AnnouncementModel.fromJson(queryDocument.data());
          updatesModels.add(updatesModel);
        }
      }

      if (updatesModels.isNotEmpty) updatesModels.sort((a, b) => b.sentAt!.compareTo(a.sentAt!));
      if (updatesModels.isEmpty) return ResultModel(error: 'announcement-detail-not-found');

      return ResultModel(data: updatesModels);
    } catch (e) {
      debugPrint('Repository: getAnnouncement error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<AnnouncementModel>> getAnnouncementById(String announcementId) async {
    debugPrint('Repository: getAnnouncementById is called with announcementId $announcementId');
    final DocumentReference<Map<String, dynamic>> documentReference;
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot;
    final Map<String, dynamic>? documentMap;
    final AnnouncementModel announcementModel;

    try {
      documentReference = ref.read(firestoreInstanceProvider).collection('announcements').doc(announcementId);
      documentSnapshot = await documentReference.get();
      documentMap = documentSnapshot.data();

      if (documentMap == null) return ResultModel(error: 'announcement-not-found');

      announcementModel = AnnouncementModel.fromJson(documentMap);
      return ResultModel(data: announcementModel);
    } catch (e) {
      debugPrint('Repository: getAnnouncementById error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // UPDATE

  Future<ResultModel<AnnouncementModel>> updateAnnouncement(AnnouncementModel announcement) async {
    debugPrint('Repository: updateAnnouncement is called with announcementId ${announcement.id}');
    final DocumentReference<Map<String, dynamic>> documentReference;
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot;
    final Map<String, dynamic>? documentMap;
    final AnnouncementModel updatedAnnouncement = announcement.copyWith();

    try {
      documentReference = ref.read(firestoreInstanceProvider).collection('announcements').doc(announcement.id);
      documentSnapshot = await documentReference.get();
      documentMap = documentSnapshot.data();

      if (documentMap == null) return ResultModel(error: 'announcement-not-found');

      await documentReference.set(updatedAnnouncement.toJson(), SetOptions(merge: true));
      return ResultModel(data: updatedAnnouncement);
    } catch (e) {
      debugPrint('Repository: updateAnnouncement error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // DELETE

  Future<ResultModel<AnnouncementModel>> deleteAnnouncement(AnnouncementModel announcement) async {
    debugPrint('Repository: deleteAnnouncement is called with announcementId ${announcement.id}');
    final DocumentReference<Map<String, dynamic>> documentReference;
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot;
    final Map<String, dynamic>? documentMap;
    final AnnouncementModel updatedAnnouncement = announcement.copyWith(deletedAt: DateTime.now());

    try {
      documentReference = ref.read(firestoreInstanceProvider).collection('announcements').doc(announcement.id);
      documentSnapshot = await documentReference.get();
      documentMap = documentSnapshot.data();

      if (documentMap == null) return ResultModel(error: 'announcement-not-found');

      await documentReference.set(updatedAnnouncement.toJson(), SetOptions(merge: true));
      return ResultModel();
    } catch (e) {
      debugPrint('Repository: deleteAnnouncement error is $e');
      return ResultModel(error: e.toString());
    }
  }
}
