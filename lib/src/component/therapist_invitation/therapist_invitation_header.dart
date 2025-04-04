import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TherapistInvitationHeader extends ConsumerStatefulWidget {
  const TherapistInvitationHeader({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TherapistInvitationHeaderState();
}

class _TherapistInvitationHeaderState extends ConsumerState<TherapistInvitationHeader> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Image.asset('assets/logo/ios_icon_transparent.png', height: 56, width: 60),
          const SizedBox(height: 8),
          PageTitleText(title: AppLocalizations.of(context)!.yourTherapist),
          const SizedBox(height: 4),
          PageDescriptionText(title: AppLocalizations.of(context)!.yourTherapistDescription),
        ],
      ),
    );
  }
}
