import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/current_text_controller/current_text_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/component_models/user_component_model/user_component_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/repository/user_repository/user_repository.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'patient_controller.g.dart';

@riverpod
FutureOr<ResultModel<List<UserModel>>> getPatientsFromFirestore(Ref ref, {bool includeTemporaryPatients = false}) async {
  final currentUser = ref.read(userControllerProvider);
  if (currentUser == null) return ResultModel(error: 'current-user-is-null');
  if (currentUser.role != RoleEnum.therapist) return ResultModel(error: 'current-user-is-not-therapist');
  final result = await ref
      .read(userRepositoryProvider.notifier)
      .getCurrentUserPatientsFromFirestore(currentUser, includeTemporaryPatients: includeTemporaryPatients);
  if (result.error != null || result.data == null) {
    debugPrint('Controller: getPatientsFromFirestore error is ${result.error}');
    return ResultModel(error: result.error);
  } else {
    return ResultModel(data: result.data);
  }
}

@riverpod
class AsyncFilteredPatients extends _$AsyncFilteredPatients {
  @override
  FutureOr<ResultModel<List<UserModel>>> build({
    bool excludeTransferedPatients = false,
    bool includeTemporaryPatients = false,
  }) async {
    final String currentText = ref.watch(currentTextControllerProvider);
    final result = await ref.watch(getPatientsFromFirestoreProvider(includeTemporaryPatients: includeTemporaryPatients).future);
    List<UserModel>? filteredPatients = [];

    debugPrint('Controller: asyncFilteredPatients patients before filtering is ${result.data?.length}');

    if (result.error != null || result.data == null) {
      debugPrint('Controller: asyncFilteredPatients error is ${result.error}');
      return ResultModel(error: result.error);
    } else {
      filteredPatients = result.data?.where((UserModel patient) {
        final String? patientName = patient.name;
        final String? patientLastName = patient.lastName;
        if (patientName == null || patientLastName == null) return false;
        return patientName.toLowerCase().contains(currentText.toLowerCase()) || patientLastName.toLowerCase().contains(currentText.toLowerCase());
      }).toList();

      debugPrint('Controller: asyncFilteredPatients filteredPatients length is: ${filteredPatients?.length}');

      if (excludeTransferedPatients) {
        filteredPatients = filteredPatients?.where((UserModel patient) => patient.transferId.isEmpty).toList();
        debugPrint('Controller: asyncFilteredPatients excludeTransferedPatients case filteredPatients length is: ${filteredPatients?.length}');
      }

      ref.read(syncFilteredPatientsProvider.notifier).syncFilteredPatients(filteredPatients!);

      ref.onDispose(() {
        ref.invalidate(getPatientsFromFirestoreProvider(includeTemporaryPatients: includeTemporaryPatients));
        ref.invalidate(syncFilteredPatientsProvider);
        ref.invalidateSelf();
      });

      return ResultModel(data: filteredPatients);
    }
  }
}

@riverpod
class SyncFilteredPatients extends _$SyncFilteredPatients {
  @override
  List<UserModel> build() => [];

  void syncFilteredPatients(List<UserModel> patients) => state = patients;
}

@Riverpod(keepAlive: true)
class FilteredPatientsForSelectionList extends _$FilteredPatientsForSelectionList {
  @override
  List<UserComponentModel> build(List<UserModel>? userModelList) {
    if (userModelList == null) return [];
    debugPrint('Controller: FilteredPatientsForSelectionList is called with userModelList: ${userModelList.length}');
    List<UserComponentModel> userComponentModelList = [];
    for (UserModel user in userModelList) {
      userComponentModelList.add(UserComponentModel(userModel: user, isSelected: false));
    }
    return userComponentModelList;
  }

  void selectUser(int index) {
    if (index < 0 || index >= state.length) return;

    final bool isSelected = state[index].isSelected;
    final UserComponentModel newState = state[index].copyWith(isSelected: !isSelected);
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) newState else state[i]
    ];
    debugPrint(
      'Controller: selectUser is called'
      'with index: $index and'
      'isSelected: ${state[index].isSelected},'
      'for userId ${state[index].userModel?.id}',
    );
  }

  void selectUserAndDeselectOthers(int index) {
    if (index < 0 || index >= state.length) return;

    final UserComponentModel newState = state[index].copyWith(isSelected: true);
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) newState else state[i].copyWith(isSelected: false)
    ];
    debugPrint(
      'Controller: selectUserAndDeselectOthers is called'
      'with index: $index and'
      'isSelected: ${state[index].isSelected},'
      'for userId ${state[index].userModel?.id}',
    );
  }

  void selectAllUsers() {
    final List<UserComponentModel> newState =
        state.map((UserComponentModel userComponentModel) => userComponentModel.copyWith(isSelected: true)).toList();
    state = newState;
  }

  void deselectAllUsers() {
    final List<UserComponentModel> newState =
        state.map((UserComponentModel userComponentModel) => userComponentModel.copyWith(isSelected: false)).toList();
    state = newState;
  }

  void decideToSelectOrDeselectAllUsers() {
    final bool allSelected = state.every((UserComponentModel userComponentModel) => userComponentModel.isSelected);
    if (allSelected) {
      deselectAllUsers();
    } else {
      selectAllUsers();
    }
  }

  bool areAllUsersSelected() => state.every((UserComponentModel userComponentModel) => userComponentModel.isSelected);
}

@riverpod
class SelectedPatients extends _$SelectedPatients {
  @override
  List<UserModel> build(List<UserModel>? userModelList) {
    if (userModelList == null) return [];
    final List<UserComponentModel> usersForSelection = ref.watch(filteredPatientsForSelectionListProvider(userModelList));
    final List<UserModel> selectedPatients =
        usersForSelection.where((UserComponentModel patient) => patient.isSelected).map((UserComponentModel patient) => patient.userModel!).toList();
    debugPrint('Controller: SelectedPatients is selected: ${selectedPatients.length} users out of: ${userModelList.length}');
    return selectedPatients;
  }
}

@Riverpod(keepAlive: true)
class CurrentPatient extends _$CurrentPatient {
  @override
  UserModel? build() => null;

  void selectUser(UserModel user) => state = user;
  void clearUser() => state = null;
  void invalidateCurrentPatientProvider() => ref.invalidateSelf();
}

@riverpod
class IsPatientListOpen extends _$IsPatientListOpen {
  @override
  bool build() => true;

  void toggleState() => state = !state;
  void openPatientList() => state = true;
  void closePatientList() => state = false;
}
