import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/theme/styles.dart';

class MediaOptionTile extends ConsumerWidget {
  const MediaOptionTile({
    super.key,
    required this.function,
    required this.text,
    required this.icon,
  });

  final Function function;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => function(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        width: 327,
        height: 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(RepathyStyle.standardRadius),
          border: Border.all(
            color: RepathyStyle.primaryColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: RepathyStyle.smallIconSize,
              color: RepathyStyle.defaultTextColor,
            ),
            SizedBox(width: 16),
            Text(
              text,
              style: TextStyle(
                fontSize: RepathyStyle.standardTextSize,
                fontWeight: RepathyStyle.standardFontWeight,
                color: RepathyStyle.defaultTextColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
