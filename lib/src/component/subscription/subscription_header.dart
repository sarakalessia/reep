import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class SubscriptionHeader extends ConsumerWidget {
  const SubscriptionHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userControllerProvider);
    final userRole = currentUser?.role;
    final isTherapist = userRole == RoleEnum.therapist;
    final title = isTherapist ? 'Licenze' : 'Abbonamenti';
    final description = isTherapist ? 'Le licenze disponibili su Repathy' : 'Gli abbonamenti disponibili su Repathy';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo/ios_icon_transparent.png',
          height: RepathyStyle.extraLargeIconSize,
          width: RepathyStyle.extraLargeIconSize,
        ),
        SizedBox(height: 10),
        PageTitleText(title: title),
        SizedBox(height: 20),
        PageDescriptionText(title: description),
        SizedBox(height: 20),
      ],
    );
  }
}
