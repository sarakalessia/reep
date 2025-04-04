import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/side_menu/side_menu_exit_button.dart';
import 'package:repathy/src/component/side_menu/side_menu_header.dart';
import 'package:repathy/src/component/side_menu/side_menu_item_body.dart';
import 'package:repathy/src/component/side_menu/side_menu_logout.dart';
import 'package:repathy/src/component/side_menu/side_menu_photo.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/theme/styles.dart';

class SideMenu extends ConsumerWidget {
  const SideMenu({super.key});

  final double spaceBetweenItems = 15;
  final FontWeight itemsFontWeight = RepathyStyle.boldFontWeight;
  final Color textColor = RepathyStyle.darkTextColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userControllerProvider);

    return Drawer(
      shape: const RoundedRectangleBorder(),
      shadowColor: RepathyStyle.defaultTextColor,
      backgroundColor: RepathyStyle.backgroundColor,
      width: MediaQuery.of(context).size.width * 0.65,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 8, 0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  const SideMenuExitButton(),
                  const SideMenuProfilePhoto(),
                  SideMenuHeader(topPadding: 16, bottomPadding: 16, userModel: currentUser),
                  SideMenuItemBody(role: currentUser!.role),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
              child: const SideMenuLogout(),
            ),
          ],
        ),
      ),
    );
  }
}
