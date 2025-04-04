import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/bottom_nav_bar_controller/bottom_nav_bar_controller.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class BottomNavBar extends ConsumerStatefulWidget {
  const BottomNavBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
  final therapistNavBarItems = const [
    BottomNavigationBarItem(
      label: '',
      icon: Icon(Icons.list),
      activeIcon: Icon(Icons.list, color: RepathyStyle.primaryColor),
    ),
    BottomNavigationBarItem(
      label: '',
      icon: Icon(Icons.home_rounded),
      activeIcon: Icon(Icons.home_rounded, color: RepathyStyle.primaryColor),
    ),
    BottomNavigationBarItem(
      label: '',
      icon: Icon(Icons.photo_camera_rounded),
      activeIcon: Icon(Icons.photo_camera_rounded, color: RepathyStyle.primaryColor),
    ),
  ];

  final patientNavBarItems = const [
    BottomNavigationBarItem(
      label: '',
      icon: Icon(Icons.person_2_rounded),
      activeIcon: Icon(Icons.person_2_rounded, color: RepathyStyle.primaryColor),
    ),
    BottomNavigationBarItem(
      label: '',
      icon: Icon(Icons.home_rounded),
      activeIcon: Icon(Icons.home_rounded, color: RepathyStyle.primaryColor),
    ),
    BottomNavigationBarItem(
      label: '',
      icon: Icon(Icons.ondemand_video_rounded),
      activeIcon: Icon(Icons.ondemand_video_rounded, color: RepathyStyle.primaryColor),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    int navBarIndexController = ref.watch(bottomNavBarIndexProvider);
    UserModel? currentUser = ref.watch(userControllerProvider);

    return Container(
      height: RepathyStyle.bottomNavigationHeight,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            blurRadius: 40,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RepathyStyle.roundedRadius),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            elevation: 4,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            useLegacyColorScheme: false,
            items: currentUser?.role == RoleEnum.therapist ? therapistNavBarItems : patientNavBarItems,
            currentIndex: navBarIndexController,
            selectedIconTheme: IconThemeData(size: 40, color: RepathyStyle.primaryColor),
            unselectedIconTheme: IconThemeData(size: 40, color: RepathyStyle.bottomNavigationIconColor),
            onTap: (int value) {
              value != navBarIndexController ? ref.read(bottomNavBarIndexProvider.notifier).setIndex(value) : null;
              ref.read(subPageControllerProvider.notifier).updateSubPage(PageEnum.none);
            },
          ),
        ),
      ),
    );
  }
}
