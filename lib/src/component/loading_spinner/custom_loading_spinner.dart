import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/theme/styles.dart';

class CustomLoadingSpinner extends ConsumerWidget {
  const CustomLoadingSpinner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.4,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: RepathyStyle.primaryColor,
              strokeWidth: 4.0,
            ),
          ],
        ),
      ),
    );
  }
}
