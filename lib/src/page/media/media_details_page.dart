import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/exercise/exercise_card.dart';
import 'package:repathy/src/component/media/media_delete_bottom_sheet.dart';
import 'package:repathy/src/component/media/media_pdf_details.dart';
import 'package:repathy/src/component/notification/comments/comments_bottom_sheet.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/component/video_player/video_card.dart';
import 'package:repathy/src/controller/exercise_controller/exercise_controller.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/util/enum/media_format_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class VideoDetailsPage extends ConsumerStatefulWidget {
  const VideoDetailsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoDetailsPageState();
}

class _VideoDetailsPageState extends ConsumerState<VideoDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final currentMedia = ref.watch(mediaControllerProvider);
    final exerciseFromVideo = ref.watch(getExercisesByMediaIdProvider(currentMedia!.id!));
    final currentUser = ref.watch(userControllerProvider);
    final fileFromStorage = ref.watch(fetchMediaFileProvider(currentMedia.mediaPath!));
    final userRole = currentUser?.role;
    final currentMediaFormat = currentMedia.mediaFormat;
    final title = currentMediaFormat != MediaFormatEnum.pdf ? 'Video' : 'PDF';

    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Align(alignment: Alignment.centerLeft, child: PageTitleText(title: title)),
            ),
            currentMediaFormat != MediaFormatEnum.pdf
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PageDescriptionText(title: currentMedia.title ?? currentMedia.painEnum.first.name),
                        IconButton(
                          onPressed: () async {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(RepathyStyle.roundedRadius),
                                  topRight: Radius.circular(RepathyStyle.roundedRadius),
                                ),
                                child: Container(
                                  color: RepathyStyle.backgroundColor,
                                  height: MediaQuery.of(context).size.height * 0.8,
                                  child: CommentsBottomSheet(),
                                ),
                              ),
                              isScrollControlled: true,
                              isDismissible: true,
                            );
                          },
                          icon:
                              Icon(Icons.comment_rounded, color: RepathyStyle.primaryColor, size: RepathyStyle.standardIconSize),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: currentMediaFormat != MediaFormatEnum.pdf
                  ? VideoCard(dataSource: currentMedia)
                  : fileFromStorage.when(
                      data: (ResultModel<File> data) {
                        debugPrint('View: VideoDetailsPage fileFromStorage is: $data');
                        final result = data.data;
                        if (result == null) return const Text('PDF non trovato');
                        if (currentUser == null) return const Text('PDF non trovato');
                        return MediaPdfDetails(result: result, currentUser: currentUser, currentMedia: currentMedia);
                      },
                      loading: () => Center(child: const CircularProgressIndicator()),
                      error: (error, stack) => Center(child: Text('PDF non trovato')),
                    ),
            ),
            if (currentMediaFormat != MediaFormatEnum.pdf) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(10, 12, 0, 12),
                child: Align(alignment: Alignment.centerLeft, child: PageDescriptionText(title: 'Istruzioni')),
              ),
              SizedBox(
                height: 220,
                child: exerciseFromVideo.when(
                  data: (final data) {
                    final result = data.data;
                    if (result == null) return const Text('No exercises found');
                    return ListView.builder(
                      itemBuilder: (context, index) => ExerciseCard(index: index, exerciseModel: result[index]),
                      itemCount: result.length,
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ),
              ),
            ],
            if (userRole == RoleEnum.therapist) ...[
              // PrimaryButton(
              //     text: 'Salva',
              //     onPressed: () async {
              //       // TODO: KEEP TRACK OF THE EXERCISE CARDS, AND UPDATE MEDIA WITH THAT
              //     }),
              PrimaryButton(
                isRemove: true,
                text: 'Elimina',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => DeleteMediaBottomSheet(currentMedia: currentMedia),
                  );
                },
              ),
            ],
            SizedBox(height: 40)
          ],
        ),
      ),
    );
  }
}
