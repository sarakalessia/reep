import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class AppBarWidget extends StatelessWidget implements PreferredSize {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!, // #00000040
            blurRadius: 40,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RepathyStyle.roundedRadius), // Adjust the radius as needed
        child: AppBar(
          clipBehavior: Clip.none,
          centerTitle: true,
          shadowColor: Colors.transparent,
          scrolledUnderElevation: 0,
          backgroundColor: RepathyStyle.backgroundColor,
          title: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final (int, PageEnum) returnRoute = ref.watch(getReturnRouteProvider(context));
                      final bool isMainPage = ref.read(isMainPageProvider(context));
                      return IconButton(
                        onPressed: () => ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: returnRoute.$1, subPage: returnRoute.$2),
                        icon: isMainPage
                            ? Image.asset(
                                'assets/logo/ios_icon_transparent.png',
                                height: RepathyStyle.giantIconSize,
                                width: RepathyStyle.giantIconSize,
                              )
                            : const Icon(
                                Icons.arrow_back_ios_new_outlined,
                                size: RepathyStyle.smallIconSize,
                                color: RepathyStyle.appBarIconColor,
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Consumer(
                builder: (context, ref, child) {
                  return IconButton(
                    onPressed: () {
                      debugPrint('View: AppBarWidget notification icon clicked with index: 1 and subPage: notifications');
                      ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 1, subPage: PageEnum.notifications);
                    },
                    icon: const Icon(
                      Icons.notifications,
                      size: RepathyStyle.standardIconSize,
                      color: RepathyStyle.appBarIconColor,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 16),
              child: IconButton(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                icon: const Icon(
                  Icons.menu,
                  size: RepathyStyle.standardIconSize,
                  color: RepathyStyle.appBarIconColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget get child => const SizedBox.shrink();

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
