import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/studio_model/studio_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:repathy/src/repository/studio_repository/studio_repository.dart';

part 'studio_controller.g.dart';

@Riverpod(keepAlive: true)
class StudioController extends _$StudioController {
  @override
  StudioModel? build() => null;

  void updateCachedStudio(StudioModel? newStudio) => state = newStudio;
  void cleanCachedStudio() => state = null;

  // CREATE

  Future<ResultModel<StudioModel>> createNewStudio({
    required UserModel studioOwner,
    String? currentSubscriptionId,
    String? studioName,
  }) async {
    debugPrint(
      'Controller: createStudio is called with'
      'studioOwnerId: ${studioOwner.id},'
      'subscriptionId $currentSubscriptionId,'
      'studioName $studioName',
    );

    final UserModel? user = ref.read(userControllerProvider);
    if (user == null) {
      final userResult = await ref.read(getCurrentUserModelFromFirestoreProvider.future);
      final user = userResult.data;
      if (user == null) return ResultModel(error: 'user-not-found');
    }

    final studioResult = await ref.read(studioRepositoryProvider.notifier).createNewStudio(
          studioOwner: studioOwner,
          currentSubscriptionId: currentSubscriptionId,
          studioName: studioName,
        );
    final studioModel = studioResult.data;
    updateCachedStudio(studioModel);
    return studioResult;
  }

  // READ

  Future<ResultModel<StudioModel>> getStudioByUserId(UserModel? user) async {
    debugPrint('Controller: getStudioByUserId is called with userId: ${user?.id}');
    if (user == null) return ResultModel(error: 'user-not-found');
    if (user.role == RoleEnum.patient) return ResultModel(error: 'patient-cannot-own-studio');
    return await ref.read(studioRepositoryProvider.notifier).getStudioByUserId(user);
  }

  Future<ResultModel<StudioModel>> getStudioById(String studioId, {bool updateCache = false}) async {
    debugPrint('Controller: getStudioById is called with studioId: $studioId');
    final studioResult = await ref.read(studioRepositoryProvider.notifier).getStudioById(studioId);
    final studioModel = studioResult.data;
    if (updateCache) updateCachedStudio(studioModel);
    return studioResult;
  }

  Future<ResultModel<bool>> checkIfStudioExists({String? studioName}) async {
    debugPrint('Controller: checkIfStudioExists is called with studioName: $studioName');
    return await ref.read(studioRepositoryProvider.notifier).checkIfStudioExists(studioName: studioName);
  }

  // UPDATE

  Future<ResultModel<StudioModel>> updateStudio(StudioModel studioModel) async {
    debugPrint('Controller: updateStudio is called with studioId: ${studioModel.id}');
    final studioResult = await ref.read(studioRepositoryProvider.notifier).updateStudio(studioModel);
    final updatedStudioModel = studioResult.data;
    updateCachedStudio(updatedStudioModel);
    return studioResult;
  }

  Future<ResultModel<String>> addStudioLogo({required File studioLogoFile, required String studioId}) async {
    debugPrint('Controller: addStudioLogo is called with studioId: $studioId');
    final result = await ref.read(studioRepositoryProvider.notifier).addStudioLogo(studioLogoFile: studioLogoFile, studioId: studioId);
    final updatedStudio = state?.copyWith(studioLogoUrl: result.data);
    if (updatedStudio != null) updateCachedStudio(updatedStudio);
    return result;
  }

  // DELETE

  Future<ResultModel<bool>> deleteStudio(String studioId) async {
    debugPrint('Controller: deleteStudio is called with studioId: $studioId');
    final result = await ref.read(studioRepositoryProvider.notifier).deleteStudio(studioId);
    if (result.data == true) cleanCachedStudio();
    return result;
  }

  Future<ResultModel<bool>> unlinkUserFromStudio({required String userId, required String studioId}) async {
    debugPrint('Controller: unlinkUserFromStudio is called with userId: $userId and studioId: $studioId');
    final result = await ref.read(studioRepositoryProvider.notifier).unlinkUserFromStudio(userId: userId, studioId: studioId);
    return result;
  }
}

// READ REACTIVELY

@riverpod
FutureOr<ResultModel<StudioModel>> getStudioByUserId(Ref ref, UserModel? userModel) async {
  return await ref.read(studioControllerProvider.notifier).getStudioByUserId(userModel);
}

@riverpod
FutureOr<ResultModel<StudioModel>> getStudioById(Ref ref, String studioId, {bool updateCache = false}) async {
  return await ref.read(studioControllerProvider.notifier).getStudioById(studioId);
}

@riverpod
FutureOr<ResultModel<bool>> checkIfStudioExists(Ref ref, {String? studioName}) async {
  return await ref.read(studioControllerProvider.notifier).checkIfStudioExists(studioName: studioName);
}