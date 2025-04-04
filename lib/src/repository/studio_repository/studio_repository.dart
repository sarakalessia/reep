import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/studio_model/studio_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'studio_repository.g.dart';

@riverpod
class StudioRepository extends _$StudioRepository {
  @override
  void build() {}

  // CREATE

  Future<ResultModel<StudioModel>> createNewStudio({
    required UserModel studioOwner,
    String? currentSubscriptionId,
    String? studioName,
  }) async {
    debugPrint(
      'Repository: createStudio is called with'
      'studioOwnerId: ${studioOwner.id},'
      'subscriptionId $currentSubscriptionId,'
      'studioName $studioName',
    );

    final studioCollection = ref.read(firestoreInstanceProvider).collection('studio');
    final studioModel = StudioModel(
      studioName: studioName,
      studioOwnerId: studioOwner.id,
      currentSubscriptionId: currentSubscriptionId,
    );
    final studioMap = studioModel.toJson();

    try {
      final createdStudio = await studioCollection.add(studioMap);
      final createdStudioSnapshot = await createdStudio.get();
      final createdStudioMap = createdStudioSnapshot.data();
      if (createdStudioMap == null) return ResultModel(error: 'Repository: createNewStudio error creating studio');
      final studioModelFromFirestore = StudioModel.fromJson(createdStudioMap);
      await createdStudio.update({'id': studioModelFromFirestore.id});
      return ResultModel(data: studioModelFromFirestore);
    } catch (e) {
      debugPrint('Repository: createNewStudio error is: $e');
      return ResultModel(error: 'Repository: createNewStudio error is: $e');
    }
  }

  // READ

  Future<ResultModel<StudioModel>> getStudioByUserId(UserModel user) async {
    debugPrint('Repository: getStudioByUserId is called with userId: ${user.id}');
    if (user.role == RoleEnum.patient) return ResultModel(error: 'patient-cannot-own-studio');

    final studioCollection = ref.read(firestoreInstanceProvider).collection('studio');

    try {
      final ownerSnapshot = await studioCollection.where('studioOwnerId', isEqualTo: user.id).get();
      if (ownerSnapshot.docs.isNotEmpty) {
        final ownerStudioData = ownerSnapshot.docs.first.data();
        final ownerStudioModel = StudioModel.fromJson(ownerStudioData);
        return ResultModel(data: ownerStudioModel);
      }

      final linkedUserSnapshot = await studioCollection.where('linkedUserIds', arrayContains: user.id).get();
      if (linkedUserSnapshot.docs.isNotEmpty) {
        final linkedUserStudioData = linkedUserSnapshot.docs.first.data();
        final linkedUserStudioModel = StudioModel.fromJson(linkedUserStudioData);
        return ResultModel(data: linkedUserStudioModel);
      }

      return ResultModel(error: 'no-studio-found');
    } catch (e) {
      debugPrint('Repository: getStudioByUserId error: $e');
      return ResultModel(error: 'Repository: getStudioByUserId error: $e');
    }
  }

  Future<ResultModel<StudioModel>> getStudioById(String studioId) async {
    debugPrint('Repository: getStudioById is called with studioId: $studioId');
    final studioCollection = ref.read(firestoreInstanceProvider).collection('studio');
    try {
      final studioSnapshot = await studioCollection.doc(studioId).get();
      final studioData = studioSnapshot.data();
      if (studioData == null) return ResultModel(error: 'studio-not-found');
      final studioModel = StudioModel.fromJson(studioData);
      return ResultModel(data: studioModel);
    } catch (e) {
      return ResultModel(error: 'Repository: getStudioById error: $e');
    }
  }

  Future<ResultModel<bool>> checkIfStudioExists({String? studioName}) async {
    debugPrint('Repository: checkIfStudioExists is called with studioName: $studioName');
    if (studioName == null) return ResultModel(error: 'no-studio-name-provided');
    final studioCollection = ref.read(firestoreInstanceProvider).collection('studio');
    final studioSnapshot = await studioCollection.get();
    final studioDocs = studioSnapshot.docs;

    try {
      for (final studio in studioDocs) {
        final studioModel = StudioModel.fromJson(studio.data());
        final studioNameFromFirestore = studioModel.studioName;
        if (studioNameFromFirestore == studioName) return ResultModel(data: true);
      }
      return ResultModel(error: 'no-studio-found');
    } catch (e) {
      debugPrint('Repository: checkIfStudioExists error: $e');
      return ResultModel(error: 'Repository: checkIfStudioExists error: $e');
    }
  }

  // UPDATE

  // ATTENTION: Prepare the updated StudioModel in the corresponding controller, or wherever this method is called
  // Some examples would be linking/unlinking users, changing the studio name, etc
  Future<ResultModel<StudioModel>> updateStudio(StudioModel updatedStudioModel) async {
    debugPrint('Repository: updateStudio is called with updatedStudioModel: ${updatedStudioModel.id}');
    final studioCollection = ref.read(firestoreInstanceProvider).collection('studio');
    final studioDoc = studioCollection.doc(updatedStudioModel.id);

    try {
      await studioDoc.update(updatedStudioModel.toJson());
      return ResultModel(data: updatedStudioModel);
    } catch (e) {
      debugPrint('Repository: updateStudio error is ${e.toString()}');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<String>> addStudioLogo({required File studioLogoFile, required String studioId}) async {
    debugPrint('Repository: addStudioLogo is called with file $studioLogoFile and studioId $studioId');
    final documentReference = ref.read(firestoreInstanceProvider).collection('studio').doc(studioId);
    final storageRef = ref.read(firebaseStorageInstanceProvider).ref().child("studio_logo").child("$studioId.png");

    try {
      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(studioLogoFile);
      await uploadTask.whenComplete(() => debugPrint('Repository: addStudioLogo file upload is complete'));

      // Get the download URL
      final String imageDownloadUrl = await storageRef.getDownloadURL();
      debugPrint('Repository: addStudioLogo image url is $imageDownloadUrl');

      // Update Firestore
      await documentReference.set({"studioLogoUrl": imageDownloadUrl}, SetOptions(merge: true));

      return ResultModel(data: imageDownloadUrl);
    } catch (e) {
      debugPrint('Repository: addStudioLogo error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // DELETE

  Future<ResultModel<bool>> deleteStudio(String studioId) async {
    debugPrint('Repository: deleteStudio is called with studioId: $studioId');
    final studioCollection = ref.read(firestoreInstanceProvider).collection('studio');
    final studioDoc = studioCollection.doc(studioId);

    try {
      await studioDoc.delete();
      return ResultModel(data: true);
    } catch (e) {
      debugPrint('Repository: deleteStudio error is ${e.toString()}');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<bool>> unlinkUserFromStudio({required String userId, required String studioId}) async {
    debugPrint('Repository: unlinkUserFromStudio is called with userId: $userId and studioId: $studioId');
    final studioCollection = ref.read(firestoreInstanceProvider).collection('studio');
    final userCollection = ref.read(firestoreInstanceProvider).collection('user');
    final studioDoc = studioCollection.doc(studioId);
    final userDoc = userCollection.doc(userId);

    try {
      await studioDoc.update({'linkedUserIds': FieldValue.arrayRemove([userId])});
      await userDoc.update({'studioId': ''});
      return ResultModel(data: true);
    } catch (e) {
      debugPrint('Repository: unlinkUserFromStudio error is ${e.toString()}');
      return ResultModel(error: e.toString());
    }
  }
}
