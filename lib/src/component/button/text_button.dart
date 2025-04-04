import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/theme/styles.dart';

class PrimaryTextButton extends ConsumerWidget {
  const PrimaryTextButton({
    super.key,
    required this.path,
    required this.supportText,
    required this.clickableText,
  });

  final String path;
  final String supportText;
  final String clickableText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () => ref.read(goRouterProvider).go(path),
      child: Row(
        children: [
          Text(
            supportText,
            style: const TextStyle(
              color: RepathyStyle.defaultTextColor,
              fontSize: RepathyStyle.miniTextSize,
            ),
          ),
          Text(
            clickableText,
            style: const TextStyle(
              color: RepathyStyle.primaryColor,
              fontSize: RepathyStyle.miniTextSize,
            ),
          ),
        ],
      ),
    );
  }
}
