import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/theme/styles.dart';

class TileSubtitleText extends ConsumerWidget {
  const TileSubtitleText({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: RepathyStyle.miniTextSize,
        fontWeight: RepathyStyle.lightFontWeight,
        color: RepathyStyle.defaultTextColor,
      ),
    );
  }
}