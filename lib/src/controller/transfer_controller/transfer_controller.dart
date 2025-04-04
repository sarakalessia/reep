import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/transfer_model/transfer_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/repository/notification_repository/notification_repository.dart';
import 'package:repathy/src/repository/transfer_repository/transfer_repository.dart';
import 'package:repathy/src/repository/user_repository/user_repository.dart';
import 'package:repathy/src/util/enum/transference_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transfer_controller.g.dart';

@riverpod
class TransferController extends _$TransferController {
  @override
  void build() {}

  // CREATE

  Future<ResultModel<TransferModel>> sendTransferRequest({
    required String patientId,
    required String substituteTherapistId,
    required String content,
  }) async {
    debugPrint(
      'Controller: sendTransferRequest is called with'
      'patientId $patientId,'
      'substituteTherapistId $substituteTherapistId,'
      'and content $content',
    );
    final currentUser = ref.read(userControllerProvider);
    if (currentUser == null) return ResultModel<TransferModel>(error: 'user-not-found');
    final transferModel = TransferModel(
      originalTherapistId: currentUser.id,
      substituteTherapistId: substituteTherapistId,
      patientId: patientId,
      content: content,
      sentAt: DateTime.now(),
    );
    final result = await ref.read(transferRepositoryProvider.notifier).sendTransferRequest(transferModel: transferModel);
    if (result.error != null) return ResultModel<TransferModel>(error: result.error);
    final title = 'Richiesta di trasferimento';
    final description = 'Hai ricevuto una richiesta di trasferimento da ${currentUser.name} ${currentUser.lastName}';
    ref.read(notificationsRepositoryProvider.notifier).notifySingleUser(substituteTherapistId, description, title);
    return result;
  }

  // UPDATE

  Future<ResultModel<bool>> updateTransferStatus({required TransferModel transfer}) async {
    debugPrint('Controller: acceptOrDeclineTransfer is called with transferId: ${transfer.id}');
    final originalTherapistResult = await ref.read(getUserModelByIdProvider(transfer.substituteTherapistId!).future);
    final substituteTherapistResult = await ref.read(getUserModelByIdProvider(transfer.substituteTherapistId!).future);
    final originalTherapistUser = originalTherapistResult.data;
    final substituteTherapistUser = substituteTherapistResult.data;
    final currentUser = ref.read(userControllerProvider);
    final isCurrentUserOriginalTherapist = currentUser?.id == originalTherapistUser?.id;
    if (originalTherapistUser == null) return ResultModel<bool>(error: 'user-not-found');

    final result = await ref.read(transferRepositoryProvider.notifier).updatedTransferStatus(transfer: transfer);
    if (result.error != null) return ResultModel<bool>(error: result.error);

    if (transfer.status == TransferStatus.accepted) {
      final title = 'Trasferimento accettato';
      final description = '${substituteTherapistUser?.name} ${substituteTherapistUser?.lastName} ha accettato la tua richiesta di trasferimento';
      ref.read(notificationsRepositoryProvider.notifier).notifySingleUser(transfer.originalTherapistId!, description, title);
    } else if (transfer.status == TransferStatus.rejected) {
      final title = 'Trasferimento rifiutato';
      final description = '${substituteTherapistUser?.name} ${substituteTherapistUser?.lastName} ha rifiutato la tua richiesta di trasferimento';
      ref.read(notificationsRepositoryProvider.notifier).notifySingleUser(transfer.originalTherapistId!, description, title);
    } else if (transfer.status == TransferStatus.revoked) {
      final title = 'Trasferimento revocato';
      if (isCurrentUserOriginalTherapist) {
        final description = '${originalTherapistUser.name} ${originalTherapistUser.lastName} ha revocato il trasferimento';
        ref.read(notificationsRepositoryProvider.notifier).notifySingleUser(transfer.substituteTherapistId!, description, title);
      } else {
        final description = '${substituteTherapistUser?.name} ${substituteTherapistUser?.lastName} ha revocato il trasferimento';
        ref.read(notificationsRepositoryProvider.notifier).notifySingleUser(transfer.originalTherapistId!, description, title);
      }
    }
    return result;
  }
}

// READ REACTIVELY

@riverpod
FutureOr<ResultModel<List<TransferModel>>> getCurrentUserTransfers(Ref ref) async {
  final currentUser = ref.read(userControllerProvider);
  if (currentUser == null) return ResultModel<List<TransferModel>>(error: 'user-not-found');
  return await ref.read(transferRepositoryProvider.notifier).getCurrentUserTransfers(currentUser);
}

@riverpod
class GetTransferList extends _$GetTransferList {
  @override
  FutureOr<(List<TransferModel>? transfers, List<UserModel>? patients, List<UserModel>? originalTherapists, List<UserModel>? substituteTherapists)> build() async {
    debugPrint('Controller: getTransferList is called');

    // First, we fetch all transfers related to the current user, with the appropriate parameters
    final ResultModel<List<TransferModel>> transfersResult = await ref.watch(getCurrentUserTransfersProvider.future);
    debugPrint('Controller: getTransferList getTransfers is $transfersResult');
    if (transfersResult.data == null) return (null, null, null, null);
    final List<TransferModel> transfers = transfersResult.data!;

    debugPrint('Controller: getTransferList getTransfers is ${transfersResult.data}');

    // Then, we fetch the current user's model for utility
    final userModel = ref.read(userControllerProvider);
    if (userModel == null) return (null, null, null, null);

    debugPrint('Controller: getTransferList userModel is $userModel');

    // Now, since the TransferModel has a patientId, originalTherapistId, and substituteTherapistId, we need to extract only the IDs where the current user is involved
    final filteredTransfers = transfers.where((element) => element.substituteTherapistId == userModel.id || element.originalTherapistId == userModel.id).toList();

    debugPrint('Controller: getTransferList filteredTransfers is $filteredTransfers');

    // Now we extract the patient, original therapist, and substitute therapist ids from the filteredTransfers
    final List<String> patientIds = filteredTransfers.map((e) => e.patientId!).toList();
    final List<String> originalTherapistIds = filteredTransfers.map((e) => e.originalTherapistId!).toList();
    final List<String> substituteTherapistIds = filteredTransfers.map((e) => e.substituteTherapistId!).toList();
    if (patientIds.isEmpty && originalTherapistIds.isEmpty && substituteTherapistIds.isEmpty) return (null, null, null, null);

    debugPrint('Controller: getTransferList patientIds is $patientIds');
    debugPrint('Controller: getTransferList originalTherapistIds is $originalTherapistIds');
    debugPrint('Controller: getTransferList substituteTherapistIds is $substituteTherapistIds');

    // Since we want to return both the appropriate transfers + a list of user models from the patients, original therapists, and substitute therapists, we need to fetch the user models
    final patientUsers = await ref.read(userRepositoryProvider.notifier).getUserModelsFromFirestoreByIds(patientIds);
    if (patientUsers.data == null) return (null, null, null, null);
    final List<UserModel> patientUserModels = patientUsers.data!;

    final originalTherapistUsers = await ref.read(userRepositoryProvider.notifier).getUserModelsFromFirestoreByIds(originalTherapistIds);
    if (originalTherapistUsers.data == null) return (null, null, null, null);
    final List<UserModel> originalTherapistUserModels = originalTherapistUsers.data!;

    final substituteTherapistUsers = await ref.read(userRepositoryProvider.notifier).getUserModelsFromFirestoreByIds(substituteTherapistIds);
    if (substituteTherapistUsers.data == null) return (null, null, null, null);
    final List<UserModel> substituteTherapistUserModels = substituteTherapistUsers.data!;

    // Create a map of patient IDs to user models
    final Map<String, UserModel> patientIdToUserModel = {for (UserModel user in patientUserModels) user.id!: user};

    // Create a map of original therapist IDs to user models
    final Map<String, UserModel> originalTherapistIdToUserModel = {for (UserModel user in originalTherapistUserModels) user.id!: user};

    // Create a map of substitute therapist IDs to user models
    final Map<String, UserModel> substituteTherapistIdToUserModel = {for (UserModel user in substituteTherapistUserModels) user.id!: user};

    // Create a list of user models that matches the order of the patient IDs
    final List<UserModel> orderedPatientUserModels = patientIds.map((id) => patientIdToUserModel[id]!).toList();

    // Create a list of user models that matches the order of the original therapist IDs
    final List<UserModel> orderedOriginalTherapistUserModels = originalTherapistIds.map((id) => originalTherapistIdToUserModel[id]!).toList();

    // Create a list of user models that matches the order of the substitute therapist IDs
    final List<UserModel> orderedSubstituteTherapistUserModels = substituteTherapistIds.map((id) => substituteTherapistIdToUserModel[id]!).toList();

    return (filteredTransfers, orderedPatientUserModels, orderedOriginalTherapistUserModels, orderedSubstituteTherapistUserModels);
  }
}