import 'package:flutter/material.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bottom_nav_bar_controller.g.dart';

@Riverpod(keepAlive: true)
class BottomNavBarIndex extends _$BottomNavBarIndex {
  @override
  int build() {
    debugPrint('Controller: bottomNavBarIndexPrivder is called');
    return 1;
  }

  void setIndex(int index) {
    debugPrint('Controller: setIndex is called with index: $index');
    state = index;
  }
}

@Riverpod(keepAlive: true)
class BottomNavBarVisibility extends _$BottomNavBarVisibility {
  @override
  bool build(BuildContext context) {
    final PageEnum currentPageController = ref.watch(currentPageControllerProvider(context));
    final shouldShow = _decideVisibilityBasedOnPageEnum(currentPageController);
    debugPrint('Controller: BottomNavBarVisibility build is called with shouldShow: $shouldShow');
    return shouldShow;
  }

  void toggleVisibility() {
    debugPrint('Controller: BottomNavBarVisibility toggleVisibility is called');
    state = !state;
  }

  bool _decideVisibilityBasedOnPageEnum(PageEnum pageEnum) {
    switch (pageEnum) {
      case  PageEnum.patientProfile ||
            PageEnum.patientHome ||
            PageEnum.painTypes ||
            PageEnum.patientListPage ||
            PageEnum.therapistHome ||
            PageEnum.library ||
            PageEnum.therapistProfile ||
            PageEnum.patientDetail ||
            PageEnum.notifications:
        return true;
      default:
        return false;
    }
  }
}
