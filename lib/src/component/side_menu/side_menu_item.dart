import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/theme/styles.dart';

class SideMenuItem extends ConsumerWidget {
  const SideMenuItem({super.key, required this.icon, required this.text, required this.actionsList});

  final IconData icon;
  final String text;
  final List<Function> actionsList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        if (actionsList.isEmpty) return;
        for (Function action in actionsList) {
          await action();
        }
      },
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: RepathyStyle.primaryColorWithOpacity,
            ),
            child: Icon(
              icon,
              color: RepathyStyle.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: RepathyStyle.sideMenusItemText,
              fontWeight: RepathyStyle.lightFontWeight,
            ),
          )
        ],
      ),
    );
  }
}
