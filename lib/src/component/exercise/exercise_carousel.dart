import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/generic_add_button.dart';
import 'package:repathy/src/component/media/media_pdf_bottom_sheet.dart';
import 'package:repathy/src/controller/exercise_list_controller/exercise_list_controller.dart';
import 'package:repathy/src/util/enum/element_size_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class ExerciseCarousel extends ConsumerStatefulWidget {
  const ExerciseCarousel({super.key, required this.index});

  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExerciseCarouselState();
}

class _ExerciseCarouselState extends ConsumerState<ExerciseCarousel> {
  @override
  Widget build(BuildContext context) {
    final exerciseListController = ref.watch(exerciseComponentListControllerProvider);

    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, exerciseListController[widget.index].images.isEmpty ? 10 : 0),
      height: exerciseListController[widget.index].images.isEmpty ? 90 : 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 120,
            width: exerciseListController[widget.index].images.isEmpty
                ? MediaQuery.sizeOf(context).width * 0.82
                : MediaQuery.sizeOf(context).width * 0.68,
            child: exerciseListController[widget.index].images.isEmpty
                ? SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Aggiungi una foto con il "+"',
                          hintStyle: TextStyle(color: RepathyStyle.inputFieldHintTextColor),
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                          filled: true,
                          fillColor: RepathyStyle.lightBackgroundColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: BorderSide(color: RepathyStyle.lightBorderColor),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                            child: GenericAddButton(
                              size: ElementSize.small,
                              function: () => showModalBottomSheet(
                                context: context,
                                builder: (context) => MediaPdfBottomSheet(index: widget.index),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: exerciseListController[widget.index].images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Image.file(
                              exerciseListController[widget.index].images[index],
                              fit: BoxFit.cover,
                              width: 100, // Set a fixed width for each image
                            ),
                            Positioned(
                              top: -10,
                              right: -10,
                              child: GestureDetector(
                                onTap: () => ref
                                    .read(exerciseComponentListControllerProvider.notifier)
                                    .removeFileFromExerciseComponentState(widget.index, exerciseListController[widget.index].images[index]),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(Icons.circle, color: RepathyStyle.errorColor, size: 30),
                                    Icon(Icons.close, color: Colors.white, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          exerciseListController[widget.index].images.isEmpty
              ? const SizedBox.shrink()
              : GenericAddButton(
                  function: () => showModalBottomSheet(
                    context: context,
                    builder: (context) => MediaPdfBottomSheet(index: widget.index),
                  ),
                ),
        ],
      ),
    );
  }
}
