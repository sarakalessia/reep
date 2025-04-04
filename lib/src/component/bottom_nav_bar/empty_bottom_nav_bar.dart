import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/theme/styles.dart';

class EmptyBottomNavBar extends ConsumerWidget {
  const EmptyBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: RepathyStyle.bottomNavigationHeight,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000), // #00000040
            blurRadius: 80,
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
            iconSize: RepathyStyle.standardIconSize,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                label: '',
                icon: CircularProgressIndicator(),
              ),
              BottomNavigationBarItem(
                label: '',
                icon: CircularProgressIndicator(),
              ),
              BottomNavigationBarItem(
                label: '',
                icon: CircularProgressIndicator(),
              ),
            ],
            selectedItemColor: RepathyStyle.backgroundColor,
            unselectedItemColor: RepathyStyle.bottomNavigationIconColor,
          ),
        ),
      ),
    );
  }
}
