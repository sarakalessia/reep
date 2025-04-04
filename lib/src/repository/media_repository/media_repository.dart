import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_interaction_model/media_interaction_model.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/util/enum/media_format_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:uuid/uuid.dart';

part 'media_repository.g.dart';

@riverpod
class MediaRepository extends _$MediaRepository {
  @override
  void build() {}

  // CREATE

  Future<ResultModel<MediaModel?>> saveMediaToFirestore({
    required UserModel userModel,
    required MediaModel media,
    required File file,
  }) async {
    debugPrint('Repository: saveMediaToFirestore is called with media: $media and file: $file');
    final ResultModel<(String?, String?)> result;
    final mediaCollectionReference = ref.read(firestoreInstanceProvider).collection('media');
    final userCollection = ref.read(firestoreInstanceProvider).collection('user');
    final userDocumentReference = userCollection.doc(userModel.id);
    final DocumentReference<Map<String, dynamic>> newDocumentReference;
    MediaModel updatedMediaModel;

    try {
      updatedMediaModel = media.copyWith(
        therapistId: userModel.id,
        createdAt: DateTime.now(),
      );

      debugPrint('Repository: saveMediaToFirestore updatedMediaModel is $updatedMediaModel');

      newDocumentReference = await mediaCollectionReference.add(updatedMediaModel.toJson());

      result = await _saveMediaToStorage(
        userModel: userModel,
        mediaId: newDocumentReference.id,
        mediaFormat: media.mediaFormat,
        file: file,
      );

      final mediaUrl = ResultModel(data: result.data?.$1);
      final uid = ResultModel(data: result.data?.$2);

      debugPrint('Repository: saveMediaToFirestore mediaUrl is $mediaUrl and uid is $uid');

      if (mediaUrl.data == null) return ResultModel(error: mediaUrl.error);

      updatedMediaModel = updatedMediaModel.copyWith(
        id: newDocumentReference.id,
        mediaPath: mediaUrl.data,
        storageUid: uid.data,
      );

      await newDocumentReference.update(updatedMediaModel.toJson());

      await userDocumentReference.update({
        'mediaIdList': FieldValue.arrayUnion([newDocumentReference.id])
      });

      debugPrint('Repository: saveMediaToFirestore is about to return $updatedMediaModel');
      return ResultModel(data: updatedMediaModel);
    } catch (e) {
      debugPrint('Repository: saveMediaToFirestore error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<(String? downloadUrl, String? uid)>> _saveMediaToStorage({
    required UserModel userModel,
    required String mediaId,
    required MediaFormatEnum mediaFormat,
    required File file,
  }) async {
    debugPrint(
      'Repository: _saveMediaToStorage is called with'
      'userModel: $userModel,'
      'mediaId: $mediaId,'
      'mediaFormat: $mediaFormat,'
      'file: $file',
    );
    final Reference storageReference;
    final StorageFolderEnum folder;
    final UploadTask uploadTask;
    final String downloadUrl;

    try {
      folder = mediaFormat.mediaToStorageConverter;
      final uniqueFileName = '${Uuid().v4()}_${DateTime.now().millisecondsSinceEpoch}.${mediaFormat.name}';

      storageReference =
          ref.read(firebaseStorageInstanceProvider).ref().child('therapists').child(userModel.id!).child(folder.name).child(uniqueFileName);

      uploadTask = storageReference.putFile(file);
      await uploadTask.whenComplete(() => debugPrint('MediaRepository: _saveMediaToStorage uploadTask completed'));

      downloadUrl = await storageReference.getDownloadURL();
      debugPrint('Repository:  _saveMediaToStorage media url is $downloadUrl');

      return ResultModel(data: (downloadUrl, uniqueFileName));
    } catch (e) {
      debugPrint('Repository: _saveMediaToStorage error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<MediaInteractionModel?>> saveMediaInteractionToFirestore(MediaModel mediaModel, UserModel currentUser) async {
    debugPrint('Repository: saveMediaInteractionToFirestore is called with mediaModel: ${mediaModel.id} and currentUser: ${currentUser.id}');
    final mediaCollectionReference = ref.read(firestoreInstanceProvider).collection('media');
    final mediaInteractionCollectionReference = mediaCollectionReference.doc(mediaModel.id).collection('media_interaction');
    final DocumentReference<Map<String, dynamic>> newDocumentReference;
    final MediaInteractionModel mediaInteractionModel;

    try {
      mediaInteractionModel = MediaInteractionModel(
        mediaId: mediaModel.id,
        patientId: currentUser.id,
        openedAt: DateTime.now(),
        mediaFormat: mediaModel.mediaFormat,
      );

      newDocumentReference = await mediaInteractionCollectionReference.add(mediaInteractionModel.toJson());

      newDocumentReference.set({'id': newDocumentReference.id}, SetOptions(merge: true));

      debugPrint('Repository: saveMediaInteractionToFirestore updated mediaInteractionModel is $mediaInteractionModel');

      return ResultModel(data: mediaInteractionModel.copyWith(id: newDocumentReference.id));
    } catch (e) {
      debugPrint('Repository: saveMediaInteractionToFirestore error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // READ

  // If this is called by the user himself, use the instead
  // When a therapist queruies a certain media from a given patient, or vice versa, we use the targetUser instead
  Future<ResultModel<List<MediaModel>>> getMediaListFromFirestore({
    UserModel? currentUser,
    UserModel? targetUser,
    MediaFormatEnum? mediaFormat,
    bool includeInteractions = false,
  }) async {
    debugPrint(
      'Repository: getMediaListFromFirestore is called with '
      'currentUserId: ${currentUser?.id}, '
      'targetUserId: ${targetUser?.id}, '
      'mediaFormat: $mediaFormat, '
      'includeInteractions: $includeInteractions',
    );

    final mediaCollectionReference = ref.read(firestoreInstanceProvider).collection('media');
    final UserModel chosenUser;
    final Query<Map<String, dynamic>> query;

    try {
      if (currentUser == null && targetUser == null) {
        debugPrint('Repository: getMediaListFromFirestore both currentUser and targetUser are null');
        return ResultModel(error: 'Nessun utente trovato');
      }

      if (targetUser == null) {
        chosenUser = currentUser!;
        debugPrint('Repository: getMediaListFromFirestore userId is null so chosenId is currentUser id ${chosenUser.id}');
      } else {
        chosenUser = targetUser;
        debugPrint('Repository: getMediaListFromFirestore userId is not null so chosenId is targetUser id ${chosenUser.id}');
      }

      if (chosenUser.role == RoleEnum.therapist) {
        query = mediaCollectionReference.where('therapistId', isEqualTo: chosenUser.id).where('deletedAt', isNull: true);
      } else if (chosenUser.role == RoleEnum.patient) {
        query = mediaCollectionReference.where('patientIds', arrayContains: chosenUser.id).where('deletedAt', isNull: true);
      } else {
        return ResultModel(error: 'Ruolo non valido');
      }

      final querySnapshot = await query.get();
      final mediaList = querySnapshot.docs.map((doc) => MediaModel.fromJson(doc.data())).toList();
      final mediaIdList = mediaList.map((media) => media.id).toList();
      final bool isTherapist = chosenUser.role == RoleEnum.therapist;

      if (includeInteractions) {
        for (int i = 0; i < mediaList.length; i++) {
          final media = mediaList[i];
          final interactionsResult = await fetchAllMediaInteractions(
            mediaId: media.id!,
            patientId: isTherapist ? null : chosenUser.id,
          );
          final updatedMedia = media.copyWith(mediaInteractions: interactionsResult.data ?? []);
          mediaList[i] = updatedMedia;
        }
      }

      debugPrint('Repository: getMediaListFromFirestore mediaList is $mediaIdList');
      return ResultModel(data: mediaList);
    } catch (e) {
      debugPrint('Repository: getMediaListFromFirestore error is: $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<List<MediaInteractionModel>>> fetchAllMediaInteractions({required String mediaId, String? patientId}) async {
    debugPrint('Repository: fetchAllMediaInteractions is called with patientId: $patientId and mediaId: $mediaId');
    final mediaCollectionReference = ref.read(firestoreInstanceProvider).collection('media');
    final mediaInteractionCollectionReference = mediaCollectionReference.doc(mediaId).collection('media_interaction');
    final mediaInteractions = <MediaInteractionModel>[];
    final Query<Map<String, dynamic>> query;

    try {
      if (patientId != null) {
        query = mediaInteractionCollectionReference.where('patientId', isEqualTo: patientId);
      } else {
        query = mediaInteractionCollectionReference;
      }

      final querySnapshot = await query.get();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in querySnapshot.docs) {
        mediaInteractions.add(MediaInteractionModel.fromJson(doc.data()));
      }

      if (mediaInteractions.isEmpty) {
        debugPrint('Repository: fetchAllMediaInteractions no media interactions found');
        return ResultModel(error: 'Non ci sono interazioni con i media');
      } else {
        debugPrint('Repository: fetchAllMediaInteractions found media interactions: $mediaInteractions');
        return ResultModel(data: mediaInteractions);
      }
    } catch (e) {
      debugPrint('Repository: fetchAllMediaInteractions error is $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<File>> fetchMediaFile(String downloadUrl) async {
    try {
      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp.pdf');
        await file.writeAsBytes(response.bodyBytes);
        return ResultModel(data: file);
      } else {
        return ResultModel(error: 'Failed to download file');
      }
    } catch (e) {
      return ResultModel(error: e.toString());
    }
  }

  // New method to pick multiple media files from the gallery
  Future<List<File>?> pickMultipleMediaFromGallery() async {
    debugPrint('Repository: pickMultipleMediaFromGallery is called');
    try {
      final List<XFile> pickedMedia = await ImagePicker().pickMultiImage(imageQuality: 100);

      if (pickedMedia.isNotEmpty) {
        debugPrint('Repository: pickMultipleMediaFromGallery picked ${pickedMedia.length} media files');
        return pickedMedia.map((xfile) => File(xfile.path)).toList();
      }
    } catch (e) {
      debugPrint('Repository: pickMultipleMediaFromGallery error picking media from gallery: $e');
    }
    return null;
  }

  Future<File?> pickMediaFromGallery({required bool isVideo}) async {
    debugPrint('Repository: pickMediaFromGallery is called with isVideo: $isVideo');
    try {
      final XFile? pickedMedia = isVideo
          ? await ImagePicker().pickVideo(source: ImageSource.gallery)
          : await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);

      debugPrint('Repository: pickMediaFromGallery pickedMedia is of type ${pickedMedia?.mimeType ?? 'unknown'} and path ${pickedMedia?.path}');

      if (pickedMedia != null) {
        debugPrint('Repository: pickMediaFromGallery Selected ${isVideo ? 'video' : 'image'} from gallery: ${pickedMedia.path}');
        return File(pickedMedia.path);
      }
    } catch (e) {
      debugPrint('Repository: pickMediaFromGallery error picking ${isVideo ? 'video' : 'image'} from gallery: $e');
    }
    return null;
  }

  Future<List<File>?> captureMultipleMediaWithCamera() async {
    debugPrint('Repository: captureMultipleMediaWithCamera is called');
    try {
      final List<XFile> capturedMedia = await ImagePicker().pickMultiImage();

      if (capturedMedia.isNotEmpty) {
        debugPrint('Repository: captureMultipleMediaWithCamera captured ${capturedMedia.length} media files');
        return capturedMedia.map((xfile) => File(xfile.path)).toList();
      }
    } catch (e) {
      debugPrint('Repository: captureMultipleMediaWithCamera error capturing media with camera: $e');
    }
    return null;
  }

  Future<File?> captureMediaWithCamera({required bool isVideo}) async {
    debugPrint('Repository: captureMediaWithCamera is called with isVideo: $isVideo');
    try {
      XFile? capturedMedia;

      if (isVideo) {
        capturedMedia = await ImagePicker().pickVideo(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
          maxDuration: const Duration(seconds: 60),
        );
        debugPrint('Repository: captureMediaWithCamera is of type ${capturedMedia?.mimeType ?? 'unknown'} and path ${capturedMedia?.path}');
      } else {
        capturedMedia = await ImagePicker().pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
        );
        debugPrint('Repository: captureMediaWithCamera is of type ${capturedMedia?.mimeType ?? 'unknown'} and path ${capturedMedia?.path}');
      }

      if (capturedMedia != null) {
        debugPrint('Controller: captureMediaWithCamera captured ${isVideo ? "video" : "image"} with camera: ${capturedMedia.path}');
        return File(capturedMedia.path);
      }
    } catch (e) {
      debugPrint('Controller: captureMediaWithCamera error capturing media with camera: $e');
    }
    return null;
  }

  // UPDATE

  Future<ResultModel<void>> linkMediaToPatients({required String mediaId, required List<String> patientIds}) async {
    debugPrint('Repository: linkMediaToPatients is called with mediaId: $mediaId and patientIds: $patientIds');
    try {
      final mediaDocumentReference = ref.read(firestoreInstanceProvider).collection('media').doc(mediaId);
      await mediaDocumentReference.update({'patientIds': patientIds});
      return ResultModel(data: null);
    } catch (e) {
      debugPrint('Error updating patientIds for media $mediaId: $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<void>> toggleMediaVisibility({required String mediaId, required bool isCurrentlyPublic}) async {
    try {
      final mediaDocumentReference = ref.read(firestoreInstanceProvider).collection('media').doc(mediaId);
      await mediaDocumentReference.update({'isPublic': !isCurrentlyPublic});
      return ResultModel(data: null);
    } catch (e) {
      debugPrint('Error toggling visibility for media $mediaId: $e');
      return ResultModel(error: e.toString());
    }
  }

  Future<ResultModel<MediaInteractionModel>> updateMediaInteraction(MediaInteractionModel mediaInteractionModel, String mediaId) async {
    debugPrint('Repository: updateMediaInteraction is called with mediaInteractionModel: $mediaInteractionModel and mediaId: $mediaId');
    final mediaCollectionReference = ref.read(firestoreInstanceProvider).collection('media');
    final mediaInteractionCollectionReference = mediaCollectionReference.doc(mediaId).collection('media_interaction');
    final DocumentReference<Map<String, dynamic>> documentReference = mediaInteractionCollectionReference.doc(mediaInteractionModel.id);
    try {
      await documentReference.update(mediaInteractionModel.toJson());
      return ResultModel(data: mediaInteractionModel);
    } catch (e) {
      debugPrint('Repository: updateMediaInteraction error is $e');
      return ResultModel(error: e.toString());
    }
  }

  // DELETE

  Future<ResultModel<void>> deleteMedia({
    required MediaModel media,
    required String therapistId,
  }) async {
    try {
      final updatedMedia = media.copyWith(deletedAt: DateTime.now());
      final mediaDocumentReference = ref.read(firestoreInstanceProvider).collection('media').doc(media.id);
      await mediaDocumentReference.update(updatedMedia.toJson());
      debugPrint('Repository: deleteMedia document id is: ${media.id}');

      final userDocumentReference = ref.read(firestoreInstanceProvider).collection('user').doc(therapistId);
      await userDocumentReference.update({
        'mediaIdList': FieldValue.arrayRemove([media.id])
      });

      final StorageFolderEnum folder = media.mediaFormat.mediaToStorageConverter;

      final storageReference = ref
          .read(firebaseStorageInstanceProvider)
          .ref()
          .child('therapists')
          .child(therapistId)
          .child(folder.name)
          .child('${media.storageUid}');

      debugPrint('Repository: deleteMedia storageReference is: ${storageReference.fullPath}');    

      await storageReference.delete();

      return ResultModel(data: null);
    } catch (e) {
      debugPrint('Repository: error deleting media ${media.id}: $e');
      return ResultModel(error: e.toString());
    }
  }
}
