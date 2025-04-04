import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/media/media_option_tile.dart';
import 'package:repathy/src/controller/exercise_list_controller/exercise_list_controller.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/theme/styles.dart';

class MediaPdfBottomSheet extends ConsumerWidget {
  const MediaPdfBottomSheet({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 473,
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(RepathyStyle.roundedRadius),
          topRight: Radius.circular(RepathyStyle.roundedRadius),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RepathyStyle.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 32),
            MediaOptionTile(
              function: () async {
                final files = await ref.read(mediaControllerProvider.notifier).captureMediaWithCamera(isVideo: false);
                if (files != null) {
                  ref
                      .read(exerciseComponentListControllerProvider.notifier)
                      .addFileListToExerciseComponentState(index, [files]);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              text: 'Foto',
              icon: Icons.camera_alt_outlined,
            ),
            MediaOptionTile(
              function: () async {
                final files = await ref.read(mediaControllerProvider.notifier).pickMultipleMediaFromGallery();
                if (files != null) {
                  ref
                      .read(exerciseComponentListControllerProvider.notifier)
                      .addFileListToExerciseComponentState(index, files);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              text: 'Importa foto',
              icon: Icons.video_camera_back_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
