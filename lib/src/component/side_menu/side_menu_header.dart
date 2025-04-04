import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SideMenuHeader extends ConsumerWidget {
  const SideMenuHeader({
    super.key,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
    required this.userModel,
  });

  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;
  final UserModel? userModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final therapistStudio = ref.watch(getStudioByUserIdProvider(userModel));

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
               Text(
                 userModel?.name ?? '',
                 style: const TextStyle(
                   fontSize: RepathyStyle.sideMenuUserNameSize,
                   fontWeight: RepathyStyle.boldFontWeight,
                 ),
                 softWrap: true,
                 overflow: TextOverflow.visible,
               ),
                if (userModel?.role == RoleEnum.therapist) ...[
                  Text(
                    userModel?.studioName ?? '',
                    style: const TextStyle(
                      fontSize: RepathyStyle.sideMenuStudioNameSize,
                      fontWeight: RepathyStyle.lightFontWeight,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  // therapistStudio.when(
                  //   data: (final data) {
                  //     final studio = data.data;
                  //     return Text(
                  //       studio?.studioName ?? '',
                  //       style: const TextStyle(
                  //         fontSize: RepathyStyle.sideMenuStudioNameSize,
                  //         fontWeight: RepathyStyle.lightFontWeight,
                  //       ),
                  //     );
                  //   },
                  //   error: (error, stackTrace) => Text(''),
                  //   loading: () => CircularProgressIndicator(),
                  // ),
                ],
                if (userModel?.role == RoleEnum.patient && userModel?.birthDate != null) ...[
                  Text(
                    '${ref.read(formControllerProvider.notifier).calculateAge(userModel!.birthDate!).toString()} ${AppLocalizations.of(context)!.yearsOld}',
                    style: const TextStyle(
                      fontSize: RepathyStyle.sideMenuStudioNameSize,
                      fontWeight: RepathyStyle.lightFontWeight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
