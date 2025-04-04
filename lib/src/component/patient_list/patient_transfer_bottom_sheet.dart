import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/controller/transfer_controller/transfer_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/transference_enum.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/util/helper/snackbar/snackbar.dart';

class PatientTransferBottomSheet extends ConsumerWidget {
  const PatientTransferBottomSheet({super.key, required this.user, required this.therapist});

  final UserModel user;
  final UserModel therapist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserTransferList = ref.watch(getCurrentUserTransfersProvider);
    final bool isTherapist = ref.read(userControllerProvider.notifier).isMainTherapist(therapist: therapist, patient: user);
    final title = isTherapist ? 'Ricuperare il paziente' : 'Ritornare il paziente';
    final description = isTherapist ? 'Vuoi davvero ripristinare il paziente' : 'Vuoi davvero ritornare il paziente';

    return Container(
      height: 473,
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(RepathyStyle.roundedRadius),
          topRight: Radius.circular(RepathyStyle.roundedRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: RepathyStyle.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
          Text(
            title,
            style: const TextStyle(
              fontSize: RepathyStyle.largeTextSize,
              fontWeight: RepathyStyle.standardFontWeight,
              color: RepathyStyle.defaultTextColor,
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '$description ${user.name} ${user.lastName}?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: RepathyStyle.standardTextSize,
                fontWeight: RepathyStyle.standardFontWeight,
                color: RepathyStyle.defaultTextColor,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
          currentUserTransferList.when(
            data: (data) {
              final transferData = data.data;
              final currentTransfer = transferData?.firstWhere((element) => element.patientId == user.id);
              return PrimaryButton(
                isRemove: true,
                text: AppLocalizations.of(context)!.confirmRequestButton,
                onPressed: () async {
                  debugPrint('View: PatientTransferBottomSheet on pressed clicked with user: ${user.id} and therapist: ${therapist.id}');
                  final updatedTransfer = currentTransfer?.copyWith(status: TransferStatus.revoked);
                  final result = await ref.read(transferControllerProvider.notifier).updateTransferStatus(transfer: updatedTransfer!);
                  if (context.mounted) Navigator.of(context).pop();
                  await ref.read(userControllerProvider.notifier).syncCachedUserWithDatabase();
                  ref.invalidate(asyncFilteredPatientsProvider(excludeTransferedPatients: false));
                  final resultData = result.data;
                  if (resultData == null) return;
                  if (resultData) ref.read(snackBarProvider(text: 'Paziente ripristinato', successOrFail: true));
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) => Text('Error: $error'),
          ),
        ],
      ),
    );
  }
}
