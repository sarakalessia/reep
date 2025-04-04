// ignore_for_file: unused_result
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/invitation_controller/invitation_controller.dart';
import 'package:repathy/src/model/data_models/invitation_model/invitation_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/invitation_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InvitesCard extends ConsumerStatefulWidget {
  const InvitesCard({
    super.key,
    required this.invitationModel,
    required this.patientUserModel,
    required this.therapistUserModel,
    required this.currentUserRole,
  });

  final InvitationModel invitationModel;
  final UserModel patientUserModel;
  final UserModel therapistUserModel;
  final RoleEnum currentUserRole;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InvitesCardState();
}

class _InvitesCardState extends ConsumerState<InvitesCard> {
  DateTime? readAt;
  String? name;
  String? subtitle;
  RoleEnum role = RoleEnum.unknown;
  InvitationStatus status = InvitationStatus.unknown;

  @override
  void initState() {
    readAt = widget.invitationModel.readAt;
    status = widget.invitationModel.status;
    debugPrint('View: InvitesCard initState is called');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    decideRole();
    decideName();
    decideSubtitle();
    debugPrint('View: InvitesCard didChangeDependencies is called');
  }

  Future<void> decideRole() async {
    switch (widget.currentUserRole) {
      case RoleEnum.therapist:
        role = RoleEnum.therapist;
        break;
      case RoleEnum.patient:
        role = RoleEnum.patient;
        break;
      case RoleEnum.unknown:
        role = RoleEnum.unknown;
        break;
    }
  }

  Future<void> decideSubtitle() async {
    switch (status) {
      case InvitationStatus.waiting:
        if (role == RoleEnum.therapist) subtitle = AppLocalizations.of(context)!.requestedToConnect;
        if (role == RoleEnum.patient) subtitle = AppLocalizations.of(context)!.awaitingToConnect;
        break;
      case InvitationStatus.accepted:
        subtitle = AppLocalizations.of(context)!.acceptedConnection;
        break;
      case InvitationStatus.rejected:
        subtitle = AppLocalizations.of(context)!.rejectedConnection;
        break;
      case InvitationStatus.unknown:
        subtitle = '';
        break;
    }
  }

  Future<void> decideName() async {
    switch (role) {
      case RoleEnum.therapist:
        name = widget.patientUserModel.name;
        break;
      case RoleEnum.patient:
        name = widget.therapistUserModel.name;
        break;
      case RoleEnum.unknown:
        name = '';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: ListTile(
        tileColor: status != InvitationStatus.waiting ? RepathyStyle.backgroundColor : RepathyStyle.primaryColor.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RepathyStyle.standardRadius),
          side: BorderSide(color: RepathyStyle.borderColor, width: 1.5),
        ),
        title: Padding(padding: const EdgeInsets.only(left: 8), child: Text(name ?? '')),
        subtitle: Padding(padding: const EdgeInsets.only(left: 8), child: Text(subtitle ?? '')),
        trailing: switch (status) {
          InvitationStatus.waiting => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (role == RoleEnum.therapist) ...[
                  IconButton(
                    icon: Icon(Icons.check_circle, size: RepathyStyle.standardIconSize, color: RepathyStyle.successColor),
                    onPressed: () async {
                      await ref
                          .read(invitationControllerProvider.notifier)
                          .acceptOrDeclineInvitation(widget.invitationModel, InvitationStatus.accepted);
                      ref.refresh(getInvitationListControllerProvider.future);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel, size: RepathyStyle.standardIconSize, color: RepathyStyle.errorColor),
                    onPressed: () async {
                      await ref
                          .read(invitationControllerProvider.notifier)
                          .acceptOrDeclineInvitation(widget.invitationModel, InvitationStatus.rejected);
                      ref.refresh(getInvitationListControllerProvider.future);
                    },
                  ),
                ]
              ],
            ),
          InvitationStatus.accepted || InvitationStatus.rejected => SizedBox.shrink(),
          InvitationStatus.unknown => SizedBox.shrink(),
        },
      ),
    );
  }
}

            // I THINK WE SHOULDN'T ALLOW USERS TO DELETE INVITATIONS
            // REJECTING THEM IS ENOUGH, THERE'S NO BENEFIT TO FULLY DELETING THEM

            // InvitationStatus.accepted || InvitationStatus.rejected => IconButton(
            //     icon: Icon(
            //       Icons.delete_outlined,
            //       size: RepathyStyle.notificationCardIconSize,
            //       color: RepathyStyle.darkTextColor,
            //     ),
            //     onPressed: () {
            //       // ADD A DELETED AT TO NOTIFICATION
            //       // POSSIBLY UPDATE A FILTERED LIST CONTROLLER
            //     },
            //   ),