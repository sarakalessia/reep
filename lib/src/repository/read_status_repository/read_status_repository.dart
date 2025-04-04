import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/model/data_models/read_status_model/read_status_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'read_status_repository.g.dart';

@riverpod
class AnnouncementRepository extends _$AnnouncementRepository {
  @override
  void build() {}

  // CREATE

  Future<ReadAtModel> createReadAtDocument(String collectionPath, String documentId, String readerId) async {
    final Map<String, dynamic> readAtMap;
    final DocumentReference<Map<String, dynamic>> documentReference;
    final DocumentSnapshot<Map<String, dynamic>> newDocumentSnapshot;
    final Map<String, dynamic>? newDocumentMap;
    ReadAtModel? newReadAt;

    try {
      newReadAt = ReadAtModel(
        readerId: readerId,
        readAt: DateTime.now(),
      );

      readAtMap = newReadAt.toJson();
      documentReference =
          await ref.read(firestoreInstanceProvider).collection(collectionPath).doc(documentId).collection('read_at').add(readAtMap);

      newDocumentSnapshot = await documentReference.get();
      newDocumentMap = newDocumentSnapshot.data();
      if (newDocumentMap == null) return ReadAtModel(readerId: 'read-at-not-found', readAt: DateTime.now());

      newReadAt = ReadAtModel.fromJson(newDocumentMap);

      return newReadAt;
    } catch (e) {
      debugPrint('Repository: createReadAtDocument error is $e');
      return ReadAtModel(readerId: 'read-at-error', readAt: DateTime.now());
    }
  }

  // READ

  Future<ResultModel<List<ReadAtModel>>> getReadAtForDocument(String collectionPath, String documentId) async {
    final List<ReadAtModel> readAtList = [];
    final QuerySnapshot<Map<String, dynamic>> querySnapshot;
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> queryDocumentSnapshots;
    final List<Map<String, dynamic>> readAtMaps;

    try {
      querySnapshot = await ref.read(firestoreInstanceProvider).collection(collectionPath).doc(documentId).collection('read_at').get();
      queryDocumentSnapshots = querySnapshot.docs;
      readAtMaps = queryDocumentSnapshots.map((e) => e.data()).toList();

      for (final readAtMap in readAtMaps) {
        readAtList.add(ReadAtModel.fromJson(readAtMap));
      }

      return ResultModel(data: readAtList);
    } catch (e) {
      debugPrint('Repository: getReadAtForDocument error is $e');
      return ResultModel(error: e.toString());
    }
  }
}
