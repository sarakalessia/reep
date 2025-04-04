import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/repository/user_repository/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_image_controller.g.dart';

@riverpod
class ImageFileController extends _$ImageFileController {
  @override
  File? build({bool isCover = false}) => null;

  Future<void> getImageFromGalleryAndSave({bool isCover = false}) async {
    debugPrint('Controller: getImageFromGalleryAndSave is called');
    try {
      final XFile? pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxWidth: 200,
      );

      if (pickedImage == null) return;

      state = File(pickedImage.path);
      debugPrint('Controller: getImageFromGalleryAndSave image from gallery is ${state.toString()}');
      await ref.read(userControllerProvider.notifier).saveProfileImage(state!, isCover: isCover);
      await ref.read(userControllerProvider.notifier).syncCachedUserWithDatabase();
    } catch (e) {
      debugPrint('Controller: getImageFromGalleryAndSave error is $e');
    }
  }

  void clearImageFile() => state = null;
}

@riverpod
NetworkImage imageFromCurrentUser(Ref ref, {bool isCover = false}) {
  try {
    final userModel = ref.watch(userControllerProvider);
    final userImage = userModel?.profileImage;
    final userCover = userModel?.coverImage;
    final chosenImage = isCover ? userCover : userImage;

    debugPrint("Controller: imageFromCurrentUser image from urlImage is: $chosenImage");
    final NetworkImage image = NetworkImage(chosenImage ?? '');
    debugPrint("Controller: imageFromCurrentUser networkImage from urlImage is: $image");
    return image;
  } catch (e) {
    debugPrint("Controller: imageFromCurrentUser error is $e");
    return const NetworkImage('');
  }
}

@riverpod
FutureOr<NetworkImage> imageFromUserId(Ref ref, String id, {bool isCover = false}) async {
  try {
    final userResult = await ref.read(getUserModelByIdProvider(id).future);
    final userModel = userResult.data;
    final userImage = userModel?.profileImage;
    final userCover = userModel?.coverImage;
    final chosenImage = isCover ? userCover : userImage;

    debugPrint("Controller: imageFromUserId image from urlImage is: $chosenImage");

    final NetworkImage image = NetworkImage(chosenImage ?? '');

    debugPrint("Controller: imageFromUserId networkImage from urlImage is: $image");

    return image;
  } catch (e) {
    debugPrint("Controller: imageFromUserId error is $e");
    return const NetworkImage('');
  }
}

@riverpod
FutureOr<NetworkImage> imageFromCurrentTherapist(Ref ref) async {
  final currentUser = ref.read(userControllerProvider);
  if (currentUser == null) return const NetworkImage("");
  final therapistResult = await ref.read(userRepositoryProvider.notifier).getCurrentUserTherapistFromFirestore(currentUser);
  final therapistModel = therapistResult.data;
  final String? userImage;

  try {
    if (therapistModel == null) {
      debugPrint("Controller: imageFromCurrentTherapist error is userModel is null");
      return const NetworkImage("");
    }

    userImage = therapistModel.profileImage;

    debugPrint("Controller: imageFromUserId image from urlImage is: $userImage");

    final NetworkImage image = NetworkImage(userImage ?? '');

    debugPrint("Controller: imageFromUserId networkImage from urlImage is: $image");

    return image;
  } catch (e) {
    debugPrint("Controller: imageFromUserId error is $e");
    return const NetworkImage('');
  }
}
