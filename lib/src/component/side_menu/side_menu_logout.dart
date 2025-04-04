import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SideMenuLogout extends ConsumerWidget {
  const SideMenuLogout({
    super.key,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
  });

  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: RepathyStyle.backgroundColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.exit_to_app,
                size: RepathyStyle.smallIconSize,
                color: RepathyStyle.darkTextColor,
              ),
              onPressed: () async {
                await ref.read(userControllerProvider.notifier).signOut();
                ref.read(goRouterProvider).go('/login');
                ref.read(userControllerProvider.notifier).invalidateCachedUser();
              },
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                await ref.read(userControllerProvider.notifier).signOut();
                ref.read(goRouterProvider).go('/login');
              },
              child: Text(
                AppLocalizations.of(context)!.sideMenuLogout,
                style: const TextStyle(
                  color: RepathyStyle.darkTextColor,
                  fontWeight: RepathyStyle.boldFontWeight,
                  fontSize: RepathyStyle.sideMenuStudioNameSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
