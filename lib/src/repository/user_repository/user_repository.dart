import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/model/data_models/announcement_model/announcement_model.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/gender_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user_repository.g.dart';

@riverpod
class UserRepository extends _$UserRepository {
  @override
  void build() {}

  // CREATE

  Future<ResultModel<UserCredential>> createUserEmailCredential({required String email, required String password}) async {
    debugPrint('Repository: createrUserEmailCredential is called');
    try {
      final userCredential =
          await ref.read(firebaseAuthInstanceProvider).createUserWithEmailAndPassword(email: email, password: password);
      debugPrint('Repository: userCredential is $userCredential');
      return ResultModel(data: userCredential);
    } on FirebaseAuthException catch (e) {
      return ResultModel(error: _translateFirebaseAuthError(e.code));
    } catch (e) {
      debugPrint('Repository: createrUserEmailCredential error is $e');
      return ResultModel(error: e.toString());
    }
  }

  String _translateFirebaseAuthError(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        debugPrint('Repository: _translateFirebaseAuthError error is email-already-in-use');
        return 'L\'email è già in uso.';
      case 'invalid-email':
        debugPrint('Repository: _translateFirebaseAuthError error is invalid-email');
        return 'L\'email inserita non è valida.';
      case 'operation-not-allowed':
        debugPrint('Repository: _translateFirebaseAuthError error is operation-not-allowed');
        return 'Errore sconosciuto. Riprova più tardi.';
      case 'weak-password':
        debugPrint('Repository: _translateFirebaseAuthError error is weak-password');
        return 'La password è troppo debole.';
      default:
        return 'Errore sconosciuto. Riprova più tardi.';
    }
  }

  Future<ResultModel<UserModel>> createUserDocument({
    required String email,
    required String? password,
    required String name,
    required String lastName,
    required RoleEnum role,
    required GenderEnum gender,
    required String? authId,
    DateTime? birthDate,
    String? professionalLicense,
    String? studioName,
    String? therapistId,
  }) async {
    debugPrint('Repository: createUserDocument is called with\n'
        'email: $email,\n'
        'name: $name,\n'
        'lastName: $lastName,\n'
        'role: $role,\n'
        'gender: $gender,\n'
        'authId: $authId,\n'
        'birthDate: $birthDate,\n'
        'professionalLicense: $professionalLicense,\n'
        'studioName: $studioName,\n'
        'therapistId: $therapistId');
    final Uuid uuid = Uuid();
    UserModel userModel;
    String? qrCodeId;

    try {
      if (role == RoleEnum.patient && birthDate == null) return ResultModel(error: 'birthdata-is-mandatory');
      if (role == RoleEnum.therapist && studioName == null) return ResultModel(error: 'office-name-is-mandatory');
      if (role == RoleEnum.therapist) qrCodeId = uuid.v4();
      if (role == RoleEnum.patient) qrCodeId = null;

      final sharedPreferencesAsync = ref.read(sharedPreferencesProvider);
      final firebaseMessagingId = await sharedPreferencesAsync.getString('fcm_token');

      userModel = UserModel(
        authId: authId,
        email: email,
        password: password,
        name: name,
        lastName: lastName,
        role: role,
        gender: gender,
        birthDate: birthDate,
        qrCodeId: qrCodeId,
        professionalLicense: professionalLicense,
        firebaseMessagingId: therapistId == null ? firebaseMessagingId : null,
        createdAt: DateTime.now(),
      );

      // TODO: ADD STUDIO LOGIC HERE IF NEEDED

      debugPrint('Repository: createUserDocument userModel is $userModel');
      final userMap = userModel.toJson();
      debugPrint('Repository: createUserDocument userMap is $userMap');
      final documentReference = await ref.read(firestoreInstanceProvider).collection('user').add(userMap);
      await documentReference.set({'id': documentReference.id}, SetOptions(merge: true));
      final newDocumentSnapshot = await documentReference.get();
      debugPrint('Repository: createUserDocument newDocumentSnapshot is $newDocumentSnapshot');
      final newDocumentMap = newDocumentSnapshot.data();
      debugPrint('Repository: createUserDocument documentReference is ${newDocumentMap ?? 'null'}');
      if (newDocumentMap == null) return ResultModel(error: 'user-not-created');
      userModel = UserModel.fromJson(newDocumentMap);
      return ResultModel(data: userModel);
    } catch (e) {
      debugPrint('Repository: createUserDocument error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<bool>> addPatientToUser(UserModel therapist, UserModel patient) async {
    debugPrint('Repository: addPatientToUser is called with therapist ${therapist.id} and patient ${patient.id}');
    try {
      final therapistDocumentReference = ref.read(firestoreInstanceProvider).collection('user').doc(therapist.id);
      final patientDocumentReference = ref.read(firestoreInstanceProvider).collection('user').doc(patient.id);
      await therapistDocumentReference.update({
        'patientId': FieldValue.arrayUnion([patient.id]),
      });
      await patientDocumentReference.update({
        'therapistId': FieldValue.arrayUnion([therapist.id]),
      });
      return ResultModel(data: true);
    } catch (e) {
      debugPrint('Repository: addPatientToUser error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // READ

  bool isAuthenticated() {
    debugPrint('Repository: isAuthenticated is called');
    final User? user = ref.read(firebaseAuthInstanceProvider).currentUser;
    final bool result = user != null;
    debugPrint('Repository: User in isAuthenticated is ${user?.uid ?? 'null'}');
    return result;
  }

  String? currentUserAuthId() {
    debugPrint('Repository: currentUserId is called');
    final String? userId = ref.read(firebaseAuthInstanceProvider).currentUser?.uid;
    debugPrint('Repository: User in isAuthenticated is ${userId ?? 'null'}');
    return userId;
  }

  Future<bool> checkIfCanCreate(String email) async {
    debugPrint('Repository: checkIfCanCreate is called with email $email');
    final querySnapshot = await ref.read(firestoreInstanceProvider).collection('user').where('email', isEqualTo: email).get();
    final bool result = querySnapshot.docs.isEmpty;
    debugPrint('Repository: checkIfCanCreate result is $result');
    return result;
  }

  Future<bool> checkIfCanRecover(String email) async {
    debugPrint('Repository: checkIfCanCreate is called with email $email');
    final querySnapshot = await ref.read(firestoreInstanceProvider).collection('user').where('email', isEqualTo: email).get();
    final bool result = querySnapshot.docs.isNotEmpty;
    debugPrint('Repository: checkIfCanCreate result is $result');
    return result;
  }

  Future<List<String>> getListOfFirebaseMessagingId(List<String> userIdList) async {
    debugPrint('Repository: getListOfFirebaseMessagingId is called with userIdList $userIdList');
    List<String> firebaseMessagingIdList = [];
    for (String userId in userIdList) {
      final ResultModel<String> firebaseMessagingId = await getFirebaseMessagingId(userId);
      final firebaseMessagingIdData = firebaseMessagingId.data;
      if (firebaseMessagingIdData != null) firebaseMessagingIdList.add(firebaseMessagingIdData);
    }
    return firebaseMessagingIdList;
  }

  Future<ResultModel<String>> getFirebaseMessagingId(String userId) async {
    final documentSnapshot = await ref.read(firestoreInstanceProvider).collection('user').doc(userId).get();
    final userMap = documentSnapshot.data() ?? {};
    if (userMap.isEmpty) return ResultModel(error: 'user-not-found');
    final userModel = UserModel.fromJson(userMap);
    final firebaseMessagingId = userModel.firebaseMessagingId;
    if (firebaseMessagingId == null) return ResultModel(error: 'firebase-messaging-id-not-found');
    debugPrint('Repository: getFirebaseMssagingId firebaseMessagingId is $firebaseMessagingId');
    return ResultModel(data: firebaseMessagingId);
  }

  Future<ResultModel<UserModel>> getTherapistByQrCodeId(String qrCodeId) async {
    debugPrint('Repository: getTherapistByQrCodeId is called with qrCodeId $qrCodeId');
    final userCollectionReference = ref.read(firestoreInstanceProvider).collection('user');
    final therapistSnapshot = await userCollectionReference.where('qrCodeId', isEqualTo: qrCodeId).get();
    final therapistDocs = therapistSnapshot.docs;
    if (therapistDocs.isEmpty) return ResultModel(error: 'therapist-not-found');
    final therapistMap = therapistDocs.first.data();
    final therapistModel = UserModel.fromJson(therapistMap);
    debugPrint('Repository: getTherapistByQrCodeId therapistModel is $therapistModel');
    return ResultModel(data: therapistModel);
  }

  Future<ResultModel<Map<String, dynamic>>> _getCurrentUserMapFromFirestore() async {
    debugPrint('Repository: getCurrentUserMapFromFirestore is called');
    final userCollectionReference = ref.read(firestoreInstanceProvider).collection('user');
    try {
      final userAuthId = currentUserAuthId();
      if (userAuthId == null) return ResultModel(error: 'user-not-authenticated');
      final userDocsSnapshot = await userCollectionReference.where('authId', isEqualTo: userAuthId).get();
      final userMap = userDocsSnapshot.docs.first.data();
      debugPrint('Repository: getCurrentUserMapFromFirestore userDocsSnapshot id is ${userMap['id']}');
      return ResultModel(data: userMap);
    } on Exception catch (e) {
      debugPrint('Repository: getCurrentUserMapFromFirestore error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<UserModel>> getUserModelFromFirestoreById(String? userId) async {
    debugPrint('Repository: getUserModelFromFirestoreById is called with $userId');
    if (userId == null) return ResultModel(error: 'user-not-found');
    final CollectionReference<Map<String, dynamic>> userCollectionReference =
        ref.read(firestoreInstanceProvider).collection('user');
    final DocumentReference<Map<String, dynamic>> userReference = userCollectionReference.doc(userId);
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot;
    try {
      userSnapshot = await userReference.get();
      final userMap = userSnapshot.data();
      if (userMap == null || userMap.isEmpty) return ResultModel(error: 'user-not-found');
      final userModel = UserModel.fromJson(userMap);
      debugPrint('Repository: getUserModelFromFirestoreById userModel is ${userModel.id}');
      return ResultModel(data: userModel);
    } catch (e) {
      debugPrint('Repository: getUserModelFromFirestoreById error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<List<UserModel>>> getUserModelsFromFirestoreByIds(List<String> userIds) async {
    debugPrint('Repository: getUserModelsFromFirestoreByIds is called with userIds $userIds');
    final CollectionReference<Map<String, dynamic>> userCollectionReference =
        ref.read(firestoreInstanceProvider).collection('user');
    final List<UserModel> userModels = [];
    try {
      for (String userId in userIds) {
        final DocumentReference<Map<String, dynamic>> userReference = userCollectionReference.doc(userId);
        final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userReference.get();
        final Map<String, dynamic>? userMap = userSnapshot.data();
        if (userMap != null && userMap.isNotEmpty) {
          final UserModel userModel = UserModel.fromJson(userMap);
          userModels.add(userModel);
          debugPrint('Repository: userModel in getUserModelsFromFirestoreByIds is $userModel');
        } else {
          debugPrint('Repository: user not found for userId $userId');
        }
      }
      return ResultModel(data: userModels);
    } catch (e) {
      debugPrint('Repository: getUserModelsFromFirestoreByIds error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<UserModel>> getCurrentUserModelFromFirestore() async {
    debugPrint('Repository: getCurrentUserModelFromFirestore is called');
    final UserModel? userModel;
    final ResultModel<Map<String, dynamic>> result;
    try {
      result = await _getCurrentUserMapFromFirestore();
      if (result.error != null && result.data == null) return ResultModel(error: result.error);
      userModel = UserModel.fromJson(result.data!);
      debugPrint('Repository: userModel in getCurrentUserModelFromFirestore is ${userModel.id}');
      return ResultModel(data: userModel);
    } catch (e) {
      debugPrint('Repository: Error when getting userDocsSnapshot in getUserData is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<List<UserModel>>> getCurrentUserPatientsFromFirestore(
    UserModel currentUser, {
    bool includeTemporaryPatients = false,
  }) async {
    debugPrint('Repository: getPatientsFromFirestore is called with currentUser ${currentUser.id}');
    final userCollectionReference = ref.read(firestoreInstanceProvider).collection('user');
    final patientIds = currentUser.patientId;
    final temporaryPatientIds = currentUser.temporaryPatientIds;
    final patientsList = <UserModel>[];

    debugPrint('Repository: getPatientsFromFirestore patientIds is $patientIds');

    try {
      for (String patientId in patientIds) {
        final patientReference = userCollectionReference.doc(patientId);
        final patientSnapshot = await patientReference.get();
        final patientMap = patientSnapshot.data() ?? {};
        if (patientMap.isNotEmpty) {
          final patientModel = UserModel.fromJson(patientMap);
          debugPrint('Repository: getPatientsFromFirestore patientId is ${patientModel.id}');
          patientsList.add(patientModel);
        }
      }

      debugPrint('Repository: getPatientsFromFirestore patients list is $patientIds');

      if (includeTemporaryPatients) {
        debugPrint('Repository: getPatientsFromFirestore includeTemporaryPatients is $includeTemporaryPatients');
        for (String temporaryPatientId in temporaryPatientIds) {
          final temporaryPatientReference = userCollectionReference.doc(temporaryPatientId);
          final temporaryPatientSnapshot = await temporaryPatientReference.get();
          final temporaryPatientMap = temporaryPatientSnapshot.data() ?? {};
          if (temporaryPatientMap.isNotEmpty) {
            final temporaryPatientModel = UserModel.fromJson(temporaryPatientMap);
            patientsList.add(temporaryPatientModel);
          }
        }
        debugPrint('Repository: getPatientsFromFirestore temporaryPatients list is $temporaryPatientIds');
      }

      debugPrint('Repository: getPatientsFromFirestore patients list is $patientIds');
      return ResultModel(data: patientsList);
    } catch (e) {
      debugPrint('Repository: getPatientsFromFirestore error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<List<UserModel>>> getAllTherapistsFromFirestore() async {
    debugPrint('Repository: getTherapistsFromFirestore is called');
    final CollectionReference<Map<String, dynamic>> userCollectionReference =
        ref.read(firestoreInstanceProvider).collection('user');
    final List<UserModel> therapistsList = [];
    final List<String?> therapistIds = [];
    try {
      QuerySnapshot<Map<String, dynamic>> therapistsSnapshot =
          await userCollectionReference.where('role', isEqualTo: 'therapist').get();
      for (var doc in therapistsSnapshot.docs) {
        final Map<String, dynamic> userMap = doc.data();
        final UserModel userModel = UserModel.fromJson(userMap);
        therapistsList.add(userModel);
        therapistIds.add(userModel.id);
      }
      debugPrint('Repository: getTherapistsFromFirestore therapists list is $therapistIds');
      return ResultModel(data: therapistsList);
    } catch (e) {
      debugPrint('Repository: getTherapistsFromFirestore error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<UserModel>> getCurrentUserTherapistFromFirestore(UserModel currentUser) async {
    debugPrint('Repository: getTherapistFromFirestore is called');
    final CollectionReference<Map<String, dynamic>> userCollectionReference =
        ref.read(firestoreInstanceProvider).collection('user');
    final List<UserModel> therapistsList = [];
    List<String> therapistIds = [];

    try {
      therapistIds = currentUser.therapistId;

      for (String therapistId in therapistIds) {
        final therapistReference = userCollectionReference.doc(therapistId);
        final therapistSnapshot = await therapistReference.get();
        final therapistMap = therapistSnapshot.data() ?? {};
        if (therapistMap.isNotEmpty) {
          final therapistModel = UserModel.fromJson(therapistMap);
          therapistsList.add(therapistModel);
        }
      }
      return ResultModel(data: therapistsList.first);
    } catch (e) {
      debugPrint('Repository: getTherapistFromFirestore error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<List<String>>> getStandardProfilePhotosFromFirestore() async {
    debugPrint('Repository: getStandardProfilePhotosFromFirestore is called');
    final Reference storageRef = ref.read(firebaseStorageInstanceProvider).ref().child("repathy_user_image");
    final List<String> imageUrls = [];

    try {
      final ListResult result = await storageRef.listAll();
      final List<Reference> allFiles = result.items;

      for (final Reference file in allFiles) {
        final String downloadUrl = await file.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      debugPrint('Repository: getStandardProfilePhotosFromFirestore imageUrls list is $imageUrls');
      return ResultModel(data: imageUrls);
    } catch (e) {
      debugPrint('Repository: getStandardProfilePhotosFromFirestore error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // UPDATE

  Future<ResultModel<bool>> resetPassword(String email) async {
    debugPrint('Repository: resetPassword is called with email $email');
    try {
      await ref.read(firebaseAuthInstanceProvider).sendPasswordResetEmail(email: email);
      return ResultModel(data: true);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          debugPrint('Repository: resetPassword error: The email address is not valid.');
          return ResultModel(error: 'invalid-email');
        case 'missing-android-pkg-name':
          debugPrint(
              'Repository: resetPassword error: An Android package name must be provided if the Android app is required to be installed.');
          return ResultModel(error: 'missing-android-pkg-name');
        case 'missing-continue-uri':
          debugPrint('Repository: resetPassword error: A continue URL must be provided in the request.');
          return ResultModel(error: 'missing-continue-uri');
        case 'missing-ios-bundle-id':
          debugPrint('Repository: resetPassword error: An iOS Bundle ID must be provided if an App Store ID is provided.');
          return ResultModel(error: 'missing-ios-bundle-id');
        case 'invalid-continue-uri':
          debugPrint('Repository: resetPassword error: The continue URL provided in the request is invalid.');
          return ResultModel(error: 'invalid-continue-uri');
        case 'unauthorized-continue-uri':
          debugPrint(
              'Repository: resetPassword error: The domain of the continue URL is not whitelisted. Whitelist the domain in the Firebase console.');
          return ResultModel(error: 'unauthorized-continue-uri');
        case 'user-not-found':
          debugPrint('Repository: resetPassword error: There is no user corresponding to the email address.');
          return ResultModel(error: 'user-not-found');
        default:
          debugPrint('Repository: resetPassword error: An unknown firebase error occurred.');
          return ResultModel(error: 'unknown-firebase-error');
      }
    } catch (e) {
      debugPrint('Repository: resetPassword error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<bool> updateUserAuthName(String name) async {
    debugPrint('Repository: updateUserAuth is called with name $name');
    final User? currentUser = ref.read(firebaseAuthInstanceProvider).currentUser;
    if (currentUser == null) return false;
    debugPrint('Repository: updateUserAuth currentUser is $currentUser');
    await currentUser.updateDisplayName(name);
    final User? updatedUser = ref.read(firebaseAuthInstanceProvider).currentUser;
    final bool hasNameChanged = updatedUser?.displayName == name;
    debugPrint('Repository: updateUserAuth hasNameChanged is $hasNameChanged');
    return hasNameChanged;
  }

  Future<ResultModel<String>> saveRepathyStandardProfileImage(String imageDownloadUrl) async {
    debugPrint('Repository: saveRepathyStandardProfileImage is called with file $imageDownloadUrl');
    try {
      final userResultFromFirestore = await getCurrentUserModelFromFirestore();
      final currentUserFromAuth = ref.read(firebaseAuthInstanceProvider).currentUser;
      if (currentUserFromAuth == null) return ResultModel(error: 'user-not-authenticated');
      if ((userResultFromFirestore.error != null) && userResultFromFirestore.data == null) {
        return ResultModel(error: userResultFromFirestore.error);
      }
      final userModel = userResultFromFirestore.data!;
      final documentReference = ref.read(firestoreInstanceProvider).collection('user').doc(userModel.id);
      await documentReference.set({"profileImage": imageDownloadUrl}, SetOptions(merge: true));
      await currentUserFromAuth.updatePhotoURL(imageDownloadUrl);
      return ResultModel(data: imageDownloadUrl);
    } catch (e) {
      debugPrint('Repository: saveProfileImage error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<bool>> saveProfileImage(File enteredImage, {bool isCover = false}) async {
    debugPrint('Repository: saveProfileImage is called with file ${enteredImage.path}');
    try {
      // Get current user and a reference to the storage object
      final ResultModel<UserModel> userResultFromFirestore = await getCurrentUserModelFromFirestore();
      final User? currentUserFromAuth = ref.read(firebaseAuthInstanceProvider).currentUser;
      if (currentUserFromAuth == null) return ResultModel(error: 'user-not-authenticated');
      if ((userResultFromFirestore.error != null) && userResultFromFirestore.data == null) {
        return ResultModel(error: userResultFromFirestore.error);
      }
      final userModel = userResultFromFirestore.data!;
      final documentReference = ref.read(firestoreInstanceProvider).collection('user').doc(userModel.id);
      final storageRef = ref.read(firebaseStorageInstanceProvider).ref().child("user_image").child("${userModel.id}.png");
      final coverRef = ref.read(firebaseStorageInstanceProvider).ref().child("therapist_cover").child("${userModel.id}.png");

      final chosenRef = isCover ? coverRef : storageRef;

      // Upload the file
      final UploadTask uploadTask = chosenRef.putFile(enteredImage);
      await uploadTask.whenComplete(() => debugPrint('Repository: saveProfileImage file upload is complete'));

      // Get the download URL
      final String imageDownloadUrl = await chosenRef.getDownloadURL();
      debugPrint('Repository: saveProfileImage image url is $imageDownloadUrl');

      // Save the download URL to the user document and the user auth
      isCover
          ? await documentReference.set({"coverImage": imageDownloadUrl}, SetOptions(merge: true))
          : await documentReference.set({"profileImage": imageDownloadUrl}, SetOptions(merge: true));
      await currentUserFromAuth.updatePhotoURL(imageDownloadUrl);
      return ResultModel(data: true);
    } catch (e) {
      debugPrint('Repository: saveProfileImage error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<bool>> updateUserDocument(UserModel updatedUserModel) async {
    debugPrint('Repository: updateUserDocument is called for user id ${updatedUserModel.id}');
    try {
      final documentReference = ref.read(firestoreInstanceProvider).collection('user').doc(updatedUserModel.id);
      final userMap = updatedUserModel.toJson();
      await documentReference.set(userMap, SetOptions(merge: true));
      return ResultModel(data: true);
    } catch (e) {
      debugPrint('Repository: updateUserDocument error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<bool> unlinkOrDeleteUser(String patientId, String therapistId, {bool shouldDelete = false}) async {
    debugPrint(
        'Repository: unlinkOrDeleteUser is called with patientId $patientId and therapistId $therapistId and shouldDelete $shouldDelete');

    try {
      // LOOK FOR THE PATIENT AND THERAPIST DOCUMENTS AND REMOVE THE LINK BETWEEN THEM
      await ref.read(firestoreInstanceProvider).collection('user').doc(patientId).update({
        'therapistId': FieldValue.arrayRemove([therapistId])
      });

      await ref.read(firestoreInstanceProvider).collection('user').doc(therapistId).update({
        'patientId': FieldValue.arrayRemove([patientId])
      });

      debugPrint('Repository: unlinkOrDeleteUser removed the link between the patient and the therapist');

      // LOOK FOR ALL MEDIA IN THE MEDIA COLLECTION WHERE patientIds CONTAINS patientId AND therapistId CONTAINS therapistId AND REMOVE THE LINK BETWEEN THEM

      final mediaCollectionReference = ref.read(firestoreInstanceProvider).collection('media');
      final mediaSnapshot = await mediaCollectionReference
          .where('patientIds', arrayContains: patientId)
          .where('therapistId', isEqualTo: therapistId)
          .get();
      final mediaDocs = mediaSnapshot.docs;
      final mediaIds = <String>[];

      for (final doc in mediaDocs) {
        final mediaId = doc.id;
        mediaIds.add(mediaId);
        final mediaData = doc.data();
        final mediaModel = MediaModel.fromJson(mediaData);
        final patientIds = mediaModel.patientIds;
        patientIds.remove(patientId);
        await mediaCollectionReference.doc(mediaId).update({'patientIds': patientIds});
      }

      debugPrint('Repository: unlinkOrDeleteUser removed the link between the media and the patient');

      // LOOK FOR ALL MEDIA IN THE mediaIdList ARRAY FROM THE PATIENT AND DELETE THOSE FROM THE mediaIds VARIABLE
      // THIS IS IMPORTANT TO MAKE SURE ONLY THE MEDIAS CREATED BY THE CURRENT THERAPIST ARE REMOVED, NOT ALL OF THEM

      final userDocRef = ref.read(firestoreInstanceProvider).collection('user').doc(patientId);
      final userDocSnapshot = await userDocRef.get();
      final userData = userDocSnapshot.data();

      if (userData != null) {
        final userModel = UserModel.fromJson(userData);
        final currentMediaIdList = List<String>.from(userModel.mediaIdList);
        currentMediaIdList.removeWhere((id) => mediaIds.contains(id));
        await userDocRef.update({'mediaIdList': currentMediaIdList});
      }

      debugPrint('Repository: unlinkOrDeleteUser removed the link between the user and the media');

      // LOOK FOR ALL ANNOUNCEMENTS IN THE announcements COLLECTION WHERE A DOCUMENT HAS BOTH senderId = therapistId
      // AND receiverIds CONTAINS patientId, THEN REMOVE patientId FROM IT

      final announcementCollectionReference = ref.read(firestoreInstanceProvider).collection('announcements');
      final announcementSnapshot = await announcementCollectionReference
          .where('senderId', isEqualTo: therapistId)
          .where('receiverIds', arrayContains: patientId)
          .get();
      final announcementDocs = announcementSnapshot.docs;
      if (announcementDocs.isEmpty) return true;

      // IF WE ARRIVE HERE, THERE ARE ANNOUNCEMENTS TO BE REMOVED BEFORE RETURNING TRUE

      for (final doc in announcementDocs) {
        final announcementId = doc.id;
        final announcementData = doc.data();
        final announcementModel = AnnouncementModel.fromJson(announcementData);
        final receiverIds = announcementModel.receiverIds;
        receiverIds.remove(patientId);
        await announcementCollectionReference.doc(announcementId).update({'receiverIds': receiverIds});
      }

      debugPrint('Repository: unlinkOrDeleteUser removed the link between the announcements and the patient');

      // WE REMOVED THE LINK BETWEEN THE USER DOCS, LINK BETWEEN MEDIA AND PATIENT AND LINK BETWEEN ANNOUNCEMENTS AND PATIENT
      // RETURN TRUE TO INDICATE SUCCESS

      if (shouldDelete) {
        debugPrint('Repository: unlinkOrDeleteUser is deleting the user');
        final userDocRef = ref.read(firestoreInstanceProvider).collection('user').doc(patientId);
        await userDocRef.delete();
      }

      debugPrint('Repository: unlinkOrDeleteUser is done');

      return true;
    } catch (e) {
      debugPrint('Repository: unlinkOrDeleteUser error is $e');
      return false;
    }
  }

  // DELETE

  Future<ResultModel<bool>> deleteProfileImage(UserModel userModel, {bool isCover = false}) async {
    debugPrint('Repository: deleteProfileImage is called with user id ${userModel.id}');
    try {
      final currentUserFromAuth = ref.read(firebaseAuthInstanceProvider).currentUser;
      if (currentUserFromAuth == null) return ResultModel(error: 'user-not-authenticated');
      final documentReference = ref.read(firestoreInstanceProvider).collection('user').doc(userModel.id);
      final profileImage = userModel.profileImage;
      final coverImage = userModel.coverImage;

      if (coverImage == null && isCover) return ResultModel(error: 'cover-image-not-found');
      if (profileImage == null && !isCover) return ResultModel(error: 'profile-image-not-found');

      if (!isCover && profileImage != null) {
        debugPrint('Repository: deleteProfileImage is deleting a repathy avatar');
        // THIS IF DEALS WITH THE CASE WHERE THE USER IS USING A REPATHY AVATAR INSTEAD OF A REAL PHOTO
        if (profileImage.contains('repathy_user_image')) {
          await documentReference.set({"profileImage": ''}, SetOptions(merge: true));
          await currentUserFromAuth.updatePhotoURL('');
          return ResultModel(data: true);
        }
      }

      // IF WE ARRIVE HERE THEN THERE'S A REAL PHOTO TO BE DELETED FROM FIRESTORE, STORAGE AND AUTH
      final storageRef = ref.read(firebaseStorageInstanceProvider).ref().child("user_image").child("${userModel.id}.png");
      final coverRef = ref.read(firebaseStorageInstanceProvider).ref().child("therapist_cover").child("${userModel.id}.png");
      final chosenRef = isCover ? coverRef : storageRef;

      await chosenRef.delete();

      if (isCover) {
        debugPrint('Repository: deleteProfileImage is deleting a cover image');
        await documentReference.set({"coverImage": ''}, SetOptions(merge: true));
        await currentUserFromAuth.updatePhotoURL('');
        return ResultModel(data: true);
      }

      debugPrint('Repository: deleteProfileImage is deleting a profile image');
      await documentReference.set({"profileImage": ''}, SetOptions(merge: true));
      await currentUserFromAuth.updatePhotoURL('');
      return ResultModel(data: true);
    } catch (e) {
      debugPrint('Repository: deleteProfileImage error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // SIGN IN AND OUT

  Future<ResultModel<UserCredential>> signInWithEmailAndPassword(String email, String password) async {
    debugPrint('Repository: signInWithEmailAndPassword is called with email $email and password $password');
    try {
      final UserCredential userCredential =
          await ref.read(firebaseAuthInstanceProvider).signInWithEmailAndPassword(email: email, password: password);
      return ResultModel(data: userCredential);
    } on FirebaseAuthException catch (e) {
      return ResultModel(error: _translateSignInError(e.code));
    } catch (e) {
      debugPrint('Repository: signInWithEmailAndPassword error is $e');
      return ResultModel(error: e.toString());
    }
  }

  String _translateSignInError(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        debugPrint('Repository: _translateSignInError error is invalid-email');
        return 'L\'email inserita non è valida.';
      case 'user-disabled':
        debugPrint('Repository: _translateSignInError error is user-disabled');
        return 'L\'utente è disabilitato.';
      case 'user-not-found':
        debugPrint('Repository: _translateSignInError error is user-not-found');
        return 'Utente non trovato.';
      case 'wrong-password':
        debugPrint('Repository: _translateSignInError error is wrong-password');
        return 'Password errata.';
      default:
        return 'Errore sconosciuto. Riprova più tardi';
    }
  }

  Future<ResultModel<bool>> signOut() async {
    debugPrint('Repository: signOut is called');
    try {
      await ref.read(firebaseAuthInstanceProvider).signOut();
      return ResultModel(data: true);
    } catch (e) {
      debugPrint('Repository: signOut error is $e');
      return ResultModel(error: e.toString());
    }
  }
}
