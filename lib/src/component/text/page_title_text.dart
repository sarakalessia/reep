import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/theme/styles.dart';

class PageTitleText extends ConsumerWidget {
  const PageTitleText({
    super.key,
    required this.title,
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  final String title;
  final double left;
  final double top;
  final double right;
  final double bottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: RepathyStyle.extraLargeTextSize,
          // fontWeight: RepathyStyle.boldFontWeight,
          color: RepathyStyle.defaultTextColor,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
