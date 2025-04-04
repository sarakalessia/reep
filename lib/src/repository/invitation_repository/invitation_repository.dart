import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/model/data_models/invitation_model/invitation_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/invitation_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'invitation_repository.g.dart';

@riverpod
class InvitationRepository extends _$InvitationRepository {
  @override
  void build() {}

  // CREATE

  Future<ResultModel<InvitationModel>> sendInvitation({
    required String receiverUserId,
    required UserModel currentUser,
    String? content,
  }) async {
    debugPrint('Repository: sendInvitation is called with receiverUserId: $receiverUserId, content: $content');
    final Map<String, dynamic> invitationMap;
    final DocumentReference<Map<String, dynamic>> documentReference;
    final DocumentSnapshot<Map<String, dynamic>> newDocumentSnapshot;
    final Map<String, dynamic>? newDocumentMap;
    InvitationModel? newInvitation;

    try {
      newInvitation = InvitationModel(
        senderId: currentUser.id,
        receiverId: receiverUserId,
        sentAt: DateTime.now(),
        content: content,
        status: InvitationStatus.waiting,
      );

      invitationMap = newInvitation.toJson();
      documentReference = await ref.read(firestoreInstanceProvider).collection('invitations').add(invitationMap);

      debugPrint('Repository: sendInvitation documentReference is $newInvitation');

      // Update the invitation with the generated ID
      await documentReference.set({'id': documentReference.id}, SetOptions(merge: true));

      // Fetch the updated document
      newDocumentSnapshot = await documentReference.get();
      newDocumentMap = newDocumentSnapshot.data();
      if (newDocumentMap == null) return ResultModel(error: 'invitation-not-found');

      debugPrint('Repository: sendInvitation newDocumentMap is $newDocumentMap');

      // Update the newInvitation object with the correct ID
      newInvitation = InvitationModel.fromJson(newDocumentMap);

      debugPrint('Repository: sendInvitation newInvitation is $newInvitation');

      // Update sender's user model
      await ref.read(firestoreInstanceProvider).collection('user').doc(currentUser.id).update({
        'invitationId': FieldValue.arrayUnion([newInvitation.id]),
      });

      // Update receiver's user model
      await ref.read(firestoreInstanceProvider).collection('user').doc(receiverUserId).update({
        'invitationId': FieldValue.arrayUnion([newInvitation.id]),
      });

      return ResultModel(data: newInvitation);
    } catch (e) {
      debugPrint('Repository: sendInvitation error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // READ

  Future<ResultModel<List<InvitationModel>>> getInvitations(UserModel currentUser) async {
    final collectionReference = ref.read(firestoreInstanceProvider).collection('invitations');
    final Query<Map<String, dynamic>> query;
    final QuerySnapshot<Map<String, dynamic>> querySnapshot;
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> queryDocuments;
    final List<String> invitationIds;
    List<InvitationModel> invitationModels = [];

    try {
      invitationIds = currentUser.invitationId;
      if (invitationIds.isEmpty) return ResultModel(error: 'invitation-list-empty');
      debugPrint('Repository: getInvitations invitationIds is $invitationIds');
      query = collectionReference.where(FieldPath.documentId, whereIn: invitationIds);
      query.where('deletedAt', isNull: true);
      querySnapshot = await query.get();
      queryDocuments = querySnapshot.docs;

      if (queryDocuments.isEmpty) return ResultModel(error: 'invitation-detail-not-found');
      debugPrint('Repository: getInvitations queryDocuments is not empty, and its value is $queryDocuments');
      for (final queryDocument in queryDocuments) {
        final invitationModel = InvitationModel.fromJson(queryDocument.data());
        debugPrint('Repository: getInvitations invitationModel is $invitationModel');
        invitationModels.add(invitationModel);
      }
      return ResultModel(data: invitationModels);
    } catch (e) {
      debugPrint('Repository: getInvitations error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // UPDATE

  Future<ResultModel<InvitationModel>> acceptOrDeclineInvitation({
    required UserModel currentUser, // therapist
    required InvitationModel invitation,
    required InvitationStatus newStatus,
  }) async {
    debugPrint('Repository: acceptOrDeclineInvitation is called with id: ${invitation.id}, and status: $newStatus');
    final InvitationModel? updatedInvitation;
    final Map<String, dynamic>? updatedInvitationMap;
    final invitationsCollection = ref.read(firestoreInstanceProvider).collection('invitations');
    final userCollection = ref.read(firestoreInstanceProvider).collection('user');

    try {
      updatedInvitation = invitation.copyWith(
        status: newStatus,
        acceptedAt: newStatus == InvitationStatus.accepted ? DateTime.now() : null,
        declinedAt: newStatus == InvitationStatus.rejected ? DateTime.now() : null,
      );
      updatedInvitationMap = updatedInvitation.toJson();
      await invitationsCollection.doc(invitation.id).update(updatedInvitationMap);

      await userCollection.doc(currentUser.id).update({
        'patientId':
            newStatus == InvitationStatus.accepted ? FieldValue.arrayUnion([invitation.senderId]) : FieldValue.arrayRemove([invitation.senderId]),
      });

      await userCollection.doc(invitation.senderId).update({
        'therapistId': newStatus == InvitationStatus.accepted ? FieldValue.arrayUnion([currentUser.id]) : FieldValue.arrayRemove([currentUser.id]),
      });

      return ResultModel(data: updatedInvitation);
    } catch (e) {
      debugPrint('Repository: acceptOrDeclineInvitation error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<bool> automaticAcceptanceViaQrCode({required String qrCodeId, required UserModel currentUser}) async {
    debugPrint('Repository: automaticAcceptanceViaQrCode is called with qrCodeId: $qrCodeId');
    final QuerySnapshot<Map<String, dynamic>> querySnapshot;
    final userCollection = ref.read(firestoreInstanceProvider).collection('user');
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> queryDocuments;
    final UserModel? therapistModel;

    try {
      // Fetch the therapist based on his qrCodeId
      querySnapshot = await userCollection.where('qrCodeId', isEqualTo: qrCodeId).get();
      queryDocuments = querySnapshot.docs;
      if (queryDocuments.isEmpty) return false;

      debugPrint('Repository: automaticAcceptanceViaQrCode queryDocuments value is $queryDocuments');

      therapistModel = UserModel.fromJson(queryDocuments.first.data());

      // Update both therapist and patient with the new relationship

      await ref.read(firestoreInstanceProvider).collection('user').doc(currentUser.id).update({
        'therapistId': FieldValue.arrayUnion([therapistModel.id]),
      });

      await ref.read(firestoreInstanceProvider).collection('user').doc(therapistModel.id).update({
        'patientId': FieldValue.arrayUnion([currentUser.id]),
      });

      return true;
    } catch (e) {
      debugPrint('Repository: automaticAcceptanceViaQrCode error is $e');
      return false;
    }
  }
}
