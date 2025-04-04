import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/theme/styles.dart';

class ExercisesAddButton extends ConsumerWidget {
  const ExercisesAddButton({super.key, required this.function});

  final Function function;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      decoration: BoxDecoration(
        color: RepathyStyle.secondaryColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: IconButton(
        onPressed: () => function(),
        icon: Icon(
          Icons.add,
          size: 34,
          color: RepathyStyle.backgroundColor,
        ),
      ),
    );
  }
}
