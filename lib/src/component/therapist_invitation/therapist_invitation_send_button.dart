import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/component/therapist_invitation/therapist_invitation_bottom_sheet.dart';
import 'package:repathy/src/util/helper/snackbar/snackbar.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/util/enum/element_size_enum.dart';

class TherapistInvitationSendButton extends ConsumerWidget {
  const TherapistInvitationSendButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PrimaryButton(
          text: AppLocalizations.of(context)!.sendRequestButton,
          size: ElementSize.standard,
          onPressed: () async {
            final selectedUser = ref.read(selectedUserProvider);
            if (selectedUser != null) {
              showModalBottomSheet(
                context: context,
                builder: (context) => TherapistInvitationBottomSheet(user: selectedUser),
              );
            } else {
               ref.read(snackBarProvider(text: AppLocalizations.of(context)!.chooseTherapist));
            }
          },
        ),
      ],
    );
  }
}
