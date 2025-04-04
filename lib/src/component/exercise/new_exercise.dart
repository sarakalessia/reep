import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/exercise/exercise_card.dart';
import 'package:repathy/src/component/text/page_description_text.dart';

class NewExercise extends ConsumerStatefulWidget {
  const NewExercise({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewExerciseState();
}

class _NewExerciseState extends ConsumerState<NewExercise> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 0, 12),
            child: Align(alignment: Alignment.centerLeft, child: PageDescriptionText(title: 'Istruzioni')),
          ),
          SizedBox(
            height: 250,
            width: MediaQuery.of(context).size.width * 0.9,
            child: ExerciseCard(),
          ),
        ],
      ),
    );
  }
}
