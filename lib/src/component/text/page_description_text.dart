import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/theme/styles.dart';

class PageDescriptionText extends ConsumerWidget {
  const PageDescriptionText({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        height: 1.2,
        fontSize: RepathyStyle.standardTextSize,
        fontWeight: RepathyStyle.lightFontWeight,
        color: RepathyStyle.defaultTextColor,
      ),
    );
  }
}
