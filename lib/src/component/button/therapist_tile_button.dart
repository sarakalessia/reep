import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/therapist_controller/therapist_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// THIS IS USED IN THE PATIENT PROFILE PAGE
// PATIENT CLICKS ON THIS TO GO TO HIS THERAPIST'S PUBLIC PROFILE

class TherapistTileButton extends ConsumerStatefulWidget {
  const TherapistTileButton({super.key, required this.therapistId});

  final String? therapistId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TherapistTileButtonState();
}

class _TherapistTileButtonState extends ConsumerState<TherapistTileButton> {
  String? gender;

  @override
  Widget build(BuildContext context) {
    final userFromId = ref.watch(getUserModelByIdProvider(widget.therapistId));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.myTherapists,
                style: TextStyle(
                  fontSize: RepathyStyle.smallTextSize,
                  fontWeight: RepathyStyle.lightFontWeight,
                ),
              )
            ],
          ),
        ),
        userFromId.when(
          data: (final data) {
            UserModel? syncUser = data.data;
            String mainText = '${syncUser?.name} ${syncUser?.lastName}';
            String secondaryText = AppLocalizations.of(context)!.inviteATherapist;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32.0),
                  border: Border.all(
                    color: RepathyStyle.inputFieldHintTextColor,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        syncUser == null ? secondaryText : mainText,
                        style: TextStyle(
                          fontSize: RepathyStyle.standardTextSize,
                          fontWeight: RepathyStyle.lightFontWeight,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (syncUser != null) {
                          ref.read(currentTherapistProvider.notifier).selectUser(syncUser);
                          ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 1, subPage: PageEnum.therapistPublicProfile);
                        } else {
                          ref.read(goRouterProvider).go('/therapist-invitation');
                        }
                      },
                      icon: Icon(Icons.arrow_forward_ios_rounded),
                    ),
                  ],
                ),
              ),
            );
          },
          error: (error, stackTrace) => SizedBox.shrink(),
          loading: () => SizedBox.shrink(),
        ),
      ],
    );
  }
}
