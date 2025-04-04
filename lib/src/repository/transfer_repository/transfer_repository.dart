import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/model/data_models/transfer_model/transfer_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/util/enum/transference_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transfer_repository.g.dart';

@riverpod
class TransferRepository extends _$TransferRepository {
  @override
  void build() {}

  // CREATE

  Future<ResultModel<TransferModel>> sendTransferRequest({required TransferModel transferModel}) async {
    debugPrint(
      'Repository: sendTransferRequest is called with'
      'substituteTherapistId: ${transferModel.substituteTherapistId},'
      'patientId: ${transferModel.patientId},'
      'originalTherapistId ${transferModel.originalTherapistId} and'
      'content: ${transferModel.content}',
    );
    final Map<String, dynamic> transferMap;
    final DocumentReference<Map<String, dynamic>> documentReference;
    final DocumentSnapshot<Map<String, dynamic>> newDocumentSnapshot;
    final Map<String, dynamic>? newDocumentMap;

    try {
      transferMap = transferModel.toJson();
      documentReference = await ref.read(firestoreInstanceProvider).collection('transfers').add(transferMap);

      debugPrint('Repository: sendTransferRequest documentReference is $documentReference');

      // Update the transfer with the generated ID
      await documentReference.set({'id': documentReference.id}, SetOptions(merge: true));

      // Fetch the updated document
      newDocumentSnapshot = await documentReference.get();
      newDocumentMap = newDocumentSnapshot.data();
      if (newDocumentMap == null) return ResultModel(error: 'transfer-not-found');

      debugPrint('Repository: sendTransferRequest newDocumentMap is $newDocumentMap');

      // Update the newTransfer object with the correct ID
      final newTransfer = TransferModel.fromJson(newDocumentMap);

      debugPrint('Repository: sendTransferRequest newTransfer is $newTransfer');

      // Update originalTherapist's user model
      await ref.read(firestoreInstanceProvider).collection('user').doc(transferModel.originalTherapistId).update({
        'transferId': FieldValue.arrayUnion([newTransfer.id]),
      });

      // Update substituteTherapist's user model
      await ref.read(firestoreInstanceProvider).collection('user').doc(transferModel.substituteTherapistId).update({
        'transferId': FieldValue.arrayUnion([newTransfer.id]),
      });

      // Update patient's user model
      await ref.read(firestoreInstanceProvider).collection('user').doc(transferModel.patientId).update({
        'transferId': FieldValue.arrayUnion([newTransfer.id]),
      });

      debugPrint('Repository: sendTransferRequest has completed all steps, and newTransfer is ${newTransfer.id}');

      return ResultModel(data: newTransfer);
    } catch (e) {
      debugPrint('Repository: sendTransferRequest error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // READ

  FutureOr<ResultModel<List<TransferModel>>> getCurrentUserTransfers(UserModel currentUser) async {
    final collectionReference = ref.read(firestoreInstanceProvider).collection('transfers');
    final Query<Map<String, dynamic>> query;
    final QuerySnapshot<Map<String, dynamic>> querySnapshot;
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> queryDocuments;
    final List<String> transferIds = currentUser.transferId;
    List<TransferModel> transferModels = [];

    debugPrint('Repository: getTransfers transferIds is $transferIds');

    try {
      if (transferIds.isEmpty) return ResultModel(error: 'transfer-list-empty');
      if (currentUser.role == RoleEnum.patient) return ResultModel(error: 'user-is-not-therapist');

      query = collectionReference.where(FieldPath.documentId, whereIn: transferIds);
      query.where('deletedAt', isNull: true);
      querySnapshot = await query.get();
      queryDocuments = querySnapshot.docs;

      if (queryDocuments.isEmpty) return ResultModel(error: 'transfer-detail-not-found');
      debugPrint('Repository: getTransfers queryDocuments is not empty, and its value is $queryDocuments');
      for (final queryDocument in queryDocuments) {
        final transferModel = TransferModel.fromJson(queryDocument.data());
        debugPrint('Repository: getTransfers transferModel is $transferModel');
        transferModels.add(transferModel);
      }
      return ResultModel(data: transferModels);
    } catch (e) {
      debugPrint('Repository: getTransfers error is $e');
      return ResultModel(error: e.toString());
    }
  }

  

  // UPDATE

  // REMEMBER TO UPDATE THE TRANSFER IN THE CONTROLLER, AND PASS IT CLEAN TO THE REPOSITORY
  Future<ResultModel<bool>> updatedTransferStatus({required TransferModel transfer}) async {
    debugPrint('Repository: acceptOrDeclineTransfer is called with id: ${transfer.id}, and status: ${transfer.status}');
    final transfersCollection = ref.read(firestoreInstanceProvider).collection('transfers');
    final userCollection = ref.read(firestoreInstanceProvider).collection('user');
    final transferStatus = transfer.status;
    Map<String, dynamic> transferMap = {};
    TransferModel updatedTransfer = transfer;

    try {
      // THE TRANSFER WAS ACCEPTED, LINK THE USER TO THE TEMPORARY THERAPIST, AND THE TEMPORARY PATIENT TO THE THERAPIST
      if (transferStatus == TransferStatus.accepted) {
        debugPrint('Repository: acceptOrDeclineTransfer transferStatus is accepted');

        await userCollection.doc(transfer.patientId).update({
          'substituteTherapistId': transfer.substituteTherapistId,
        });

        await userCollection.doc(transfer.substituteTherapistId).update({
          'temporaryPatientIds': FieldValue.arrayUnion([transfer.patientId]),
        });

        updatedTransfer = transfer.copyWith(acceptedAt: DateTime.now());
      }

      // THE TRANSFER WAS REVOKED, REMOVE THE TEMPORARY THERAPIST AND PATIENT FROM EACH OTHER
      if (transferStatus == TransferStatus.revoked) {
        debugPrint('Repository: acceptOrDeclineTransfer transferStatus is revoked');

        await userCollection.doc(transfer.patientId).update({
          'substituteTherapistId': null,
          'transferId': FieldValue.arrayRemove([transfer.id]),
        });

        await userCollection.doc(transfer.substituteTherapistId).update({
          'temporaryPatientIds': FieldValue.arrayRemove([transfer.patientId]),
          'transferId': FieldValue.arrayRemove([transfer.id]),
        });

        updatedTransfer = transfer.copyWith(revokedAt: DateTime.now());
      }

      transferMap = updatedTransfer.toJson();
      await transfersCollection.doc(transfer.id).update(transferMap);

      // IF THE TRANSFER WAS REJECTED, DO NOTHING TO USERS, THEY HAVEN'T BEEN LINKED YET

      return ResultModel(data: true);
    } catch (e) {
      debugPrint('Repository: acceptOrDeclineTransfer error is $e');
      return ResultModel(error: e.toString());
    }
  }
}
