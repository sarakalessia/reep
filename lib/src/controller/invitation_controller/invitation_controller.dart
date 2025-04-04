import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/invitation_model/invitation_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/repository/invitation_repository/invitation_repository.dart';
import 'package:repathy/src/repository/notification_repository/notification_repository.dart';
import 'package:repathy/src/repository/user_repository/user_repository.dart';
import 'package:repathy/src/util/enum/invitation_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'invitation_controller.g.dart';

@riverpod
class InvitationController extends _$InvitationController {
  @override
  void build() {}

  // CREATE

  Future<void> handleInvitation(UserModel userModel, BuildContext context) async {
    debugPrint('Controller: handleInvitation is called with userModel $userModel');
    final currentUser = ref.read(userControllerProvider);
    if (currentUser == null) return;
    await ref.read(invitationRepositoryProvider.notifier).sendInvitation(receiverUserId: userModel.id!, currentUser: currentUser).then((value) async {
      if (value.data != null && context.mounted) {
        debugPrint('Controller: handleInvitation flow has now written the invitation to firestore');
        await ref.read(notificationsRepositoryProvider.notifier).notifySingleUser(
              userModel.id!,
              AppLocalizations.of(context)!.inviteRequestReceivedDescription,
              AppLocalizations.of(context)!.inviteRequestReceived,
            );

        debugPrint('Controller: handleInvitation has sent the notification via cloud function');
      }
    });
  }

  // UPDATE

  Future<ResultModel<InvitationModel>> acceptOrDeclineInvitation(InvitationModel invitation, InvitationStatus newInvitationStatus) async {
    debugPrint('Controller: acceptOrDeclineInvitation is called with invitationId ${invitation.id} and newInvitationStatus $newInvitationStatus');
    final currentUser = ref.read(userControllerProvider);
    if (currentUser == null) return ResultModel<InvitationModel>(error: 'No user found');
    return await ref
        .read(invitationRepositoryProvider.notifier)
        .acceptOrDeclineInvitation(invitation: invitation, newStatus: newInvitationStatus, currentUser: currentUser);
  }

  Future<bool> automaticAcceptanceViaQrCode(String qrCodeId) async {
    debugPrint('Controller: automaticAcceptanceViaQrCode is called with invitationId $qrCodeId');
    final currentUser = ref.read(userControllerProvider);
    if (currentUser == null) return false;
    return await ref.read(invitationRepositoryProvider.notifier).automaticAcceptanceViaQrCode(qrCodeId: qrCodeId, currentUser: currentUser);
  }
}

@riverpod
FutureOr<ResultModel<List<InvitationModel>>> getInvitationListController(Ref ref) async {
  final currentUser = ref.read(userControllerProvider);
  if (currentUser == null) return ResultModel<List<InvitationModel>>(error: 'No user found');
  return await ref.read(invitationRepositoryProvider.notifier).getInvitations(currentUser);
}

// READ

@riverpod
class GetInvitationList extends _$GetInvitationList {
  @override
  FutureOr<(List<InvitationModel>? invitations, List<UserModel>? patient, List<UserModel>? therapist, RoleEnum currentUserRole)> build() async {
    debugPrint('Controller: getInvitationList is called');

    // First, we fetch all invitations related to the current user, with the appropriate parameters
    final ResultModel<List<InvitationModel>> invitationsResult = await ref.watch(getInvitationListControllerProvider.future);
    debugPrint('Controller: getInvitationList getInvitations is $invitationsResult');
    if (invitationsResult.data == null) return (null, null, null, RoleEnum.unknown);
    final List<InvitationModel> invitations = invitationsResult.data!;

    debugPrint('Controller: getInvitationList getInvitations is ${invitationsResult.data}');

    // Then, we fetch the current user's model for utility
    final userModel = ref.read(userControllerProvider);
    if (userModel == null) return (null, null, null, RoleEnum.unknown);

    debugPrint('Controller: getInvitationList userModel is $userModel');

    // Now, since the InvitationModel has a patientId and therapistId, we need to extract only the IDs where the current user is the therapist or patient
    final filteredInvitations = invitations.where((element) => element.receiverId == userModel.id || element.senderId == userModel.id).toList();

    debugPrint('Controller: getInvitationList filteredInvitations is $filteredInvitations');

    // Now we extract the patient and therapist ids from the filteredInvitations
    final List<String> patientIds = filteredInvitations.map((e) => e.senderId!).toList();
    final List<String> therapistIds = filteredInvitations.map((e) => e.receiverId!).toList();
    if (patientIds.isEmpty && therapistIds.isEmpty) return (null, null, null, RoleEnum.unknown);

    debugPrint('Controller: getInvitationList patientIds is $patientIds');
    debugPrint('Controller: getInvitationList therapistIds is $therapistIds');

    // Since we want to return both the appropriate invitations + a list of user models from the patients and therapists, we need to fetch the user models
    final patientUsers = await ref.read(userRepositoryProvider.notifier).getUserModelsFromFirestoreByIds(patientIds);
    if (patientUsers.data == null) return (null, null, null, RoleEnum.unknown);
    final List<UserModel> patientUserModels = patientUsers.data!;

    final therapistUsers = await ref.read(userRepositoryProvider.notifier).getUserModelsFromFirestoreByIds(therapistIds);
    if (therapistUsers.data == null) return (null, null, null, RoleEnum.unknown);
    final List<UserModel> therapistUserModels = therapistUsers.data!;

    debugPrint('Controller: getInvitationList patientUserModels is $patientUserModels');
    debugPrint('Controller: getInvitationList therapistUserModels is $therapistUserModels');

    // Create a map of patient IDs to user models
    final Map<String, UserModel> patientIdToUserModel = {for (UserModel user in patientUserModels) user.id!: user};

    // Create a map of therapist IDs to user models
    final Map<String, UserModel> therapistIdToUserModel = {for (UserModel user in therapistUserModels) user.id!: user};

    // Create a list of user models that matches the order of the patient IDs
    final List<UserModel> orderedpatientUserModels = patientIds.map((id) => patientIdToUserModel[id]!).toList();

    // Create a list of user models that matches the order of the therapist IDs
    final List<UserModel> orderedtherapistUserModels = therapistIds.map((id) => therapistIdToUserModel[id]!).toList();

    return (filteredInvitations, orderedpatientUserModels, orderedtherapistUserModels, userModel.role);
  }
}
