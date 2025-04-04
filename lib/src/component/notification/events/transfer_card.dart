import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/transfer_controller/transfer_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/transfer_model/transfer_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/gender_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/util/enum/transference_enum.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:repathy/src/util/helper/snackbar/snackbar.dart';

class TransferCard extends ConsumerStatefulWidget {
  const TransferCard({
    super.key,
    required this.transferModel,
    required this.patientUserModel,
    required this.originalTherapistUserModel,
    required this.substituteTherapistUserModel,
    required this.currentUser,
  });

  final TransferModel transferModel;
  final UserModel patientUserModel;
  final UserModel originalTherapistUserModel;
  final UserModel substituteTherapistUserModel;
  final UserModel currentUser;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InvitesCardState();
}

class _InvitesCardState extends ConsumerState<TransferCard> {
  String? name;
  String? subtitle;
  String? articleBasedOnGender = '';
  RoleEnum role = RoleEnum.unknown;
  TransferStatus status = TransferStatus.unknown;
  bool isCurrentUserOriginalTherapist = false;
  bool isCurrentUserSubstituteTherapist = false;
  bool showButtons = false;

  @override
  void initState() {
    debugPrint('View: TransferCard initState is called with transferModel: ${widget.transferModel.id} and patientId: ${widget.patientUserModel.id} and originalTherapistId: ${widget.originalTherapistUserModel.id} and substituteTherapistId: ${widget.substituteTherapistUserModel.id}');
    status = widget.transferModel.status;
    isCurrentUserOriginalTherapist = widget.currentUser.id == widget.originalTherapistUserModel.id;
    isCurrentUserSubstituteTherapist = widget.currentUser.id == widget.substituteTherapistUserModel.id;
    articleBasedOnGender = widget.patientUserModel.gender == GenderEnum.male ? 'il' : 'la';
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadDependencies();
  }

  void loadDependencies() {
    switch (status) {
      case TransferStatus.waiting:
        if (isCurrentUserOriginalTherapist) {
          name = widget.substituteTherapistUserModel.name;
          subtitle = 'Non ti ha ancora risposto riguardo al trasferimento di: ${widget.patientUserModel.name}';
        }
        if (isCurrentUserSubstituteTherapist) {
          name = widget.originalTherapistUserModel.name;
          subtitle = 'Vuole trasferirti: ${widget.patientUserModel.name}';
          showButtons = true;
        }
        break;
      case TransferStatus.accepted:
        if (isCurrentUserOriginalTherapist) {
          name = widget.substituteTherapistUserModel.name;
          subtitle = 'Ha accettato il trasferimento di: ${widget.patientUserModel.name}';
        }
        if (isCurrentUserSubstituteTherapist) {
          name = 'Complimenti!';
          subtitle = 'Hai accettato il trasferimento di: ${widget.patientUserModel.name}';
        }
        break;
      case TransferStatus.rejected:
        if (isCurrentUserOriginalTherapist) {
          name = widget.substituteTherapistUserModel.name;
          subtitle = 'Ha rifiutato il trasferimento di: ${widget.patientUserModel.name}';
        }
        if (isCurrentUserSubstituteTherapist) {
          name = 'Confermato!';
          subtitle = 'Hai rifiutato il trasferimento di: ${widget.patientUserModel.name}';
        }
        break;
      case TransferStatus.revoked:
        if (isCurrentUserOriginalTherapist) {
          name = widget.substituteTherapistUserModel.name;
          subtitle = 'Ha revocato il trasferimento di: ${widget.patientUserModel.name}';
        }
        if (isCurrentUserSubstituteTherapist) {
          name = 'Confermato!';
          subtitle = 'Hai revocato il trasferimento di: ${widget.patientUserModel.name}';
        }
        break;
      case TransferStatus.unknown:
        subtitle = '';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: ListTile(
        tileColor: status != TransferStatus.waiting ? RepathyStyle.backgroundColor : RepathyStyle.primaryColor.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RepathyStyle.standardRadius),
          side: BorderSide(color: RepathyStyle.borderColor, width: 1.5),
        ),
        title: Padding(padding: const EdgeInsets.only(left: 8), child: Text(name ?? '')),
        subtitle: Padding(padding: const EdgeInsets.only(left: 8), child: Text(subtitle ?? '')),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrentUserSubstituteTherapist && showButtons) ...[
              IconButton(
                icon: Icon(Icons.check_circle, size: RepathyStyle.standardIconSize, color: RepathyStyle.successColor),
                onPressed: () async {
                  await ref
                      .read(transferControllerProvider.notifier)
                      .updateTransferStatus(transfer: widget.transferModel.copyWith(status: TransferStatus.accepted));
                  await ref.read(userControllerProvider.notifier).syncCachedUserWithDatabase();   
                  ref.read(snackBarProvider(text: 'Trasferimento accettato', successOrFail: true)); 
                  ref.invalidate(getCurrentUserTransfersProvider);
                },
              ),
              IconButton(
                icon: Icon(Icons.cancel, size: RepathyStyle.standardIconSize, color: RepathyStyle.errorColor),
                onPressed: () async {
                  await ref
                      .read(transferControllerProvider.notifier)
                      .updateTransferStatus(transfer: widget.transferModel.copyWith(status: TransferStatus.rejected));
                  await ref.read(userControllerProvider.notifier).syncCachedUserWithDatabase();   
                  ref.read(snackBarProvider(text: 'Trasferimento rifiutato'));  
                  ref.invalidate(getCurrentUserTransfersProvider);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}