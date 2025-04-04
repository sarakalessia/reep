import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/side_menu/side_menu_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/controller/bottom_nav_bar_controller/bottom_nav_bar_controller.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';

class SideMenuItemBody extends ConsumerWidget {
  const SideMenuItemBody({super.key, this.spaceBetweenItems = 15, required this.role});

  final double spaceBetweenItems;
  final RoleEnum role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (role == RoleEnum.therapist) ...[
          SideMenuItem(
            icon: Icons.person_outline_outlined,
            text: AppLocalizations.of(context)!.sideMenuProfile,
            actionsList: [
              () => ref.read(bottomNavBarIndexProvider.notifier).setIndex(1),
              () {
                if (role == RoleEnum.patient) return ref.read(subPageControllerProvider.notifier).updateSubPage(PageEnum.patientProfile);
                if (role == RoleEnum.therapist) return ref.read(subPageControllerProvider.notifier).updateSubPage(PageEnum.therapistProfile);
              },
              () => Scaffold.of(context).closeEndDrawer(),
            ],
          ),
        ],
        SizedBox(height: spaceBetweenItems),
        SideMenuItem(
          icon: Icons.settings_outlined,
          text: AppLocalizations.of(context)!.sideMenuSettings,
          actionsList: [
            () => ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 1, subPage: PageEnum.settings),
            () => Scaffold.of(context).closeEndDrawer(),
          ],
        ),
        SizedBox(height: spaceBetweenItems),
      ],
    );
  }
}
