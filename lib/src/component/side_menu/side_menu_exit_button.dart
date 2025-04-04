import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/theme/styles.dart';

class SideMenuExitButton extends ConsumerWidget {
  const SideMenuExitButton({
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => Scaffold.of(context).closeEndDrawer(),
            icon: const Icon(
              Icons.close,
              size: RepathyStyle.smallIconSize,
              color: RepathyStyle.darkTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
