import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/controller/invitation_controller/invitation_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/theme/styles.dart';

class TherapistInvitationBottomSheet extends ConsumerWidget {
  const TherapistInvitationBottomSheet({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: RepathyStyle.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
          Text(
            '${AppLocalizations.of(context)!.maleTherapistConfirmation} ${user.name}?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: RepathyStyle.standardTextSize,
              fontWeight: RepathyStyle.standardFontWeight,
              color: RepathyStyle.defaultTextColor,
            ),
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.1),
          PrimaryButton(
            text: AppLocalizations.of(context)!.confirmRequestButton,
            onPressed: () async {
              debugPrint('View: TherapistInvitationBottomSheet on pressed clicked with user: ${user.name} and gender ${user.gender.name}');
              await ref.read(invitationControllerProvider.notifier).handleInvitation(user, context);
              if (context.mounted) Navigator.of(context).pop();
              ref.read(goRouterProvider).go(
                '/invitation-sent',
                extra: {
                  'name': '${user.name} ${user.lastName}',
                  'gender': user.gender.name,
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
