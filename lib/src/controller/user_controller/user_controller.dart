import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/controller/profile_image_controller/profile_image_controller.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/util/helper/snackbar/snackbar.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/repository/user_repository/user_repository.dart';
import 'package:repathy/src/util/enum/gender_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_controller.g.dart';

@Riverpod(keepAlive: true)
class UserController extends _$UserController {
  @override
  UserModel? build() => null;

  // STATE

  void updateCachedUser(UserModel user) => state = user;
  void invalidateCachedUser() => state = null;

  Future<void> syncCachedUserWithDatabase() async {
    final result = await ref.read(userRepositoryProvider.notifier).getCurrentUserModelFromFirestore();
    final data = result.data;
    if (data == null) return;
    state = data.copyWith();
  }

  // BUSINESS LOGIC

  bool isMainTherapist({required UserModel therapist, required UserModel patient}) {
    if (therapist.role != RoleEnum.therapist || patient.role != RoleEnum.patient) return false;
    final String mainTherapist = patient.therapistId.first;
    final String therapistId = therapist.id!;
    return therapistId == mainTherapist;
  }

  // CREATE

  Future<ResultModel<UserModel>> handleUserCreation({
    required String email,
    required String? password,
    required String name,
    required String lastName,
    required RoleEnum role,
    required GenderEnum gender,
    DateTime? birthDate,
    String? professionalLicense,
    String? studioName,
    bool createdByTherapist = false,
  }) async {
    ResultModel<UserCredential> userCredential;
    String? userAuthId;

    if (createdByTherapist == false && password != null) {
      userCredential = await ref.read(userRepositoryProvider.notifier).createUserEmailCredential(email: email, password: password);
      debugPrint('Controller: userCredential in handleUserCreation is $userCredential');
      userAuthId = userCredential.data?.user?.uid;
      debugPrint('Controller: userAuthId in handleUserCreation is $userAuthId');
      if (userCredential.error != null || userAuthId == null) {
        debugPrint('Controller: handleUserCreation error is ${userCredential.error}');
        await ref.read(snackBarProvider(text: 'Email è già stato utilizzato', successOrFail: false).future);
        return ResultModel(error: userCredential.error);
      }
    }

    final userDocument = await ref.read(userRepositoryProvider.notifier).createUserDocument(
          email: email,
          password: password,
          name: name,
          lastName: lastName,
          role: role,
          gender: gender,
          authId: userAuthId,
          birthDate: birthDate,
          studioName: studioName,
          professionalLicense: professionalLicense,
          therapistId: createdByTherapist ? state?.id : null,
        );

    if (userDocument.error != null || userDocument.data == null) {
      debugPrint('Controller: handleUserCreation error is ${userDocument.error}');
      return ResultModel(error: userDocument.error);
    } else {
      if (createdByTherapist && state != null) await ref.read(userRepositoryProvider.notifier).addPatientToUser(state!, userDocument.data!);
      debugPrint('Controller: handleUserCreation document is $userDocument');
      return ResultModel(data: userDocument.data);
    }
  }

  // READ OPERATIONS ARE DEFINED IN SEPARATE PROVIDERS BELOW

  // UPDATE

  Future<ResultModel<bool>> updateUserDocument({
    String? email,
    String? password,
    String? name,
    String? lastName,
    String? phoneNumber,
    String? addressString,
    String? description,
    GenderEnum? gender,
    DateTime? birthDate,
    String? studioName,
    double? height,
    double? weight,
    String? patientIdArg,
  }) async {
    final UserModel? currentUserModel = state;
    if (currentUserModel == null) return ResultModel(error: 'current-user-is-null');
    final updatedUserModel = currentUserModel.copyWith(
      email: email,
      password: password,
      name: name,
      lastName: lastName,
      gender: gender ?? currentUserModel.gender,
      birthDate: birthDate,
      description: description,
      phoneNumber: phoneNumber,
      addressString: addressString,
      studioName: studioName,
      height: height,
      weight: weight,
      patientId: patientIdArg != null ? [...currentUserModel.patientId, patientIdArg] : currentUserModel.patientId,
    );

    final result = await ref.read(userRepositoryProvider.notifier).updateUserDocument(updatedUserModel);

    if (result.error != null) {
      debugPrint('Controller: updateUserDocument error is ${result.error}');
      return ResultModel(error: result.error);
    } else {
      return ResultModel(data: result.data);
    }
  }

  Future<ResultModel<String>> saveRepathyStandardProfileImage(String imageDownloadUrl) async {
    debugPrint('Controller: saveRepathyStandardProfileImage is called with imageDownloadUrl: $imageDownloadUrl');
    final result = await ref.read(userRepositoryProvider.notifier).saveRepathyStandardProfileImage(imageDownloadUrl);
    if (result.error != null) {
      debugPrint('Controller: saveRepathyStandardProfileImage error is ${result.error}');
      return ResultModel(error: result.error);
    } else {
      debugPrint('Controller: saveRepathyStandardProfileImage result is ${result.data}');
      await syncCachedUserWithDatabase();
      return ResultModel(data: result.data);
    }
  }

  Future<ResultModel<bool>> saveProfileImage(File enteredImage, {bool isCover = false}) async {
    debugPrint('Controller: saveProfileImage is called');
    final result = await ref.read(userRepositoryProvider.notifier).saveProfileImage(enteredImage, isCover: isCover);
    if (result.error != null) {
      debugPrint('Controller: saveProfileImage error is ${result.error}');
      return ResultModel(error: result.error);
    } else {
      return ResultModel(data: result.data);
    }
  }

  Future<bool> updateUserAuthName(String text) async {
    debugPrint('Controller: updateUserAuthName is called with text: $text');
    return await ref.read(userRepositoryProvider.notifier).updateUserAuthName(text);
  }

  Future<bool> unlinkOrDeleteUser(String patientId, String therapistId, {bool shouldDelete = false}) async {
    debugPrint('Controller: unlinkOrDeleteUser is called with patientId: $patientId and therapistId: $therapistId');
    return await ref.read(userRepositoryProvider.notifier).unlinkOrDeleteUser(patientId, therapistId, shouldDelete: shouldDelete);
  }

  Future<ResultModel<bool>> resetPassword(String email) async {
    debugPrint('Controller: resetPassword is called with email: $email');
    return await ref.read(userRepositoryProvider.notifier).resetPassword(email);
  }

  // DELETE

  Future<ResultModel<bool>> deleteProfileImage({bool isCover = false}) async {
    debugPrint('Controller: deleteProfileImage is called');
    UserModel? currentUser = state;
    if (currentUser == null) return ResultModel(error: 'current-user-is-null');
    final result = await ref.read(userRepositoryProvider.notifier).deleteProfileImage(currentUser, isCover: isCover);
    if (result.error != null) {
      debugPrint('Controller: deleteProfileImage error is ${result.error}');
      ref.read(snackBarProvider(text: 'ops... qualcosa è andato storto', successOrFail: false));
      return ResultModel(error: result.error);
    } else {
      debugPrint('Controller: deleteProfileImage result is ${result.data}');
      ref.read(imageFileControllerProvider(isCover: isCover).notifier).clearImageFile();
      await syncCachedUserWithDatabase();
      return ResultModel(data: result.data);
    }
  }

  // SIGN IN AND OUT

  Future<ResultModel<UserCredential>> signInWithEmailAndPassword(String email, String password) async {
    debugPrint('Controller: signInWithEmailAndPassword is called with email: $email and password: $password');
    invalidateCachedUser();
    final result = await ref.read(userRepositoryProvider.notifier).signInWithEmailAndPassword(email, password);
    if (result.error != null || result.data == null) {
      debugPrint('Controller: signInWithEmailAndPassword error is ${result.error}');
      ref.read(snackBarProvider(text: 'ops... qualcosa è andato storto', successOrFail: false));
      return ResultModel(error: result.error);
    } else {
      return ResultModel(data: result.data);
    }
  }

  Future<ResultModel<bool>> signOut() async => await ref.read(userRepositoryProvider.notifier).signOut();

  Future<List<String>> convertUserModelListToUserIdList(List<UserModel> userModelList) async {
    final List<String> userIdList = [];
    for (UserModel userModel in userModelList) {
      userIdList.add(userModel.id!);
    }
    return userIdList;
  }
}

// READ REACTIVELY

// USER

@riverpod
Future<ResultModel<UserModel>> getCurrentUserModelFromFirestore(Ref ref) async {
  final UserModel? cachedUser = ref.read(userControllerProvider);
  if (cachedUser != null) return ResultModel(data: cachedUser);
  final ResultModel<UserModel> result = await ref.read(userRepositoryProvider.notifier).getCurrentUserModelFromFirestore();
  if (result.error != null || result.data == null) {
    debugPrint('Controller: Error in getCurrentUserModelFromFirestore is ${result.error}');
    return ResultModel(error: result.error);
  } else {
    ref.read(userControllerProvider.notifier).updateCachedUser(result.data!);
    return ResultModel(data: result.data);
  }
}

@riverpod
FutureOr<ResultModel<UserModel>> getUserModelById(Ref ref, String? id) async {
  if (id == null) return ResultModel(error: 'id-is-null');
  return await ref.read(userRepositoryProvider.notifier).getUserModelFromFirestoreById(id);
}

@riverpod
FutureOr<ResultModel<List<String>>> getStandardProfilePhotosFromFirestore(Ref ref) async {
  final result = await ref.read(userRepositoryProvider.notifier).getStandardProfilePhotosFromFirestore();
  debugPrint('Controller: getStandardProfilePhotosFromFirestore result is $result');
  return result;
}

@riverpod
class SelectedUser extends _$SelectedUser {
  @override
  UserModel? build() => null;

  void selectUser(UserModel user) => state = user;
  void clearUser() => state = null;
}

@riverpod
bool isAuthenticated(Ref ref) => ref.read(userRepositoryProvider.notifier).isAuthenticated();

@riverpod
Future<bool> isFirstTime(Ref ref) async {
  final SharedPreferencesAsync prefs = ref.read(sharedPreferencesProvider);
  final bool isFirstTime = await prefs.getBool('isFirstTime') ?? true;
  if (isFirstTime) prefs.setBool('isFirstTime', false);
  return isFirstTime;
}
