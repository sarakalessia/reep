import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/theme/styles.dart';

class SectionTitleDescription extends ConsumerWidget {
  const SectionTitleDescription({
    super.key,
    required this.title,
    required this.description,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
  });

  final String title;
  final String description;
  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: RepathyStyle.defaultTextColor,
                  fontSize: RepathyStyle.standardTextSize,
                  fontWeight: RepathyStyle.standardFontWeight,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color: RepathyStyle.defaultTextColor,
                  fontSize: RepathyStyle.smallTextSize,
                  fontWeight: RepathyStyle.lightFontWeight,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
