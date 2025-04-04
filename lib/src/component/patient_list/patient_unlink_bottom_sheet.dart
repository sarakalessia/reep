import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/util/helper/snackbar/snackbar.dart';

class PatientUnlinkOrDeleteBottomSheet extends ConsumerWidget {
  const PatientUnlinkOrDeleteBottomSheet({super.key, required this.user, required this.therapist});

  final UserModel user;
  final UserModel therapist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userHasAuth = user.authId != null;
    final title = userHasAuth ? 'Anulla collegamento' : 'Rimove l\'utente';
    final description =
        userHasAuth ? AppLocalizations.of(context)!.patientRemovalConfirmation : AppLocalizations.of(context)!.patientDeletionConfirmation;
    final snackBarText =
        userHasAuth ? 'Il paziente ${user.name} è stato rimosso con successo' : 'Il paziente ${user.name} è stato eliminato con successo';

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
          PrimaryButton(
            isRemove: true,
            text: AppLocalizations.of(context)!.confirmRequestButton,
            onPressed: () async {
              debugPrint('View: PatientUnlinkOrDeleteBottomSheet on pressed clicked with user: ${user.id} and therapist: ${therapist.id}');
              await ref.read(userControllerProvider.notifier).unlinkOrDeleteUser(user.id!, therapist.id!, shouldDelete: !userHasAuth);
              if (context.mounted) Navigator.of(context).pop();
              ref.read(userControllerProvider.notifier).syncCachedUserWithDatabase();
              ref.read(snackBarProvider(text: snackBarText, successOrFail: true));
            },
          ),
        ],
      ),
    );
  }
}
