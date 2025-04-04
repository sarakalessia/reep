import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/current_text_controller/current_text_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/repository/user_repository/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'therapist_controller.g.dart';

@riverpod
FutureOr<ResultModel<UserModel>> getTherapistByQrCodeId(Ref ref, String? qrCodeId) async {
  if (qrCodeId == null) return ResultModel(error: 'qrCodeId-is-null');
  return await ref.read(userRepositoryProvider.notifier).getTherapistByQrCodeId(qrCodeId);
}

@riverpod
FutureOr<ResultModel<List<UserModel>>> getAllTherapistsFromFirestore(Ref ref) async {
  final result = await ref.read(userRepositoryProvider.notifier).getAllTherapistsFromFirestore();
  if (result.error != null || result.data == null) {
    debugPrint('Controller: getTherapistsFromFirestore error is ${result.error}');
    return ResultModel(error: result.error);
  } else {
    return ResultModel(data: result.data);
  }
}

@riverpod
FutureOr<ResultModel<List<UserModel>>> asyncFilteredTherapists(Ref ref, {bool removeMyself = false}) async {
  debugPrint('Controller: asyncFilteredTherapists is called');
  final currentText = ref.watch(currentTextControllerProvider);
  final currentUser = ref.read(userControllerProvider);
  final result = await ref.read(getAllTherapistsFromFirestoreProvider.future);

  debugPrint('Controller: asyncFilteredTherapists therapists before filtering is ${result.data?.length}');

  if (result.error != null || result.data == null) {
    debugPrint('Controller: asyncFilteredTherapists error is ${result.error}');
    return ResultModel(error: result.error);
  } else {
    List<UserModel>? filteredTherapists = result.data?.where((UserModel therapist) {
      final String? therapistName = therapist.name;
      final String? therapistLastName = therapist.lastName;
      if (therapistName == null || therapistLastName == null) return false;
      return therapistName.toLowerCase().contains(currentText.toLowerCase()) || therapistLastName.toLowerCase().contains(currentText.toLowerCase());
    }).toList();

    debugPrint('Controller: asyncFilteredTherapists filteredTherapists length is: ${filteredTherapists?.length}');

    if (removeMyself) {
      debugPrint('Controller: asyncFilteredTherapists removeMyself case');
      final String? currentUserId = currentUser?.id;
      if (currentUserId != null) filteredTherapists = filteredTherapists?.where((UserModel therapist) => therapist.id != currentUserId).toList();
      debugPrint('Controller: asyncFilteredTherapists removeMyself case filteredTherapists length is: ${filteredTherapists?.length}');
    }

    ref.read(syncFilteredTherapistsProvider.notifier).syncFilteredPatients(filteredTherapists!);

    return ResultModel(data: filteredTherapists);
  }
}

@riverpod
class SyncFilteredTherapists extends _$SyncFilteredTherapists {
  @override
  List<UserModel> build() => [];

  void syncFilteredPatients(List<UserModel> patients) => state = patients;
}

@Riverpod(keepAlive: true)
class CurrentTherapist extends _$CurrentTherapist {
  @override
  UserModel? build() => null;

  void selectUser(UserModel user) => state = user;
  void clearUser() => state = null;
  void invalidateCurrentTherapistProvider() => ref.invalidateSelf();
}