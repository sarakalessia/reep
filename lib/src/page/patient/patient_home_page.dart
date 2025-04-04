import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/patient_home/therapist_card_for_patients.dart';
import 'package:repathy/src/component/therapist_home/section_card.dart';
import 'package:repathy/src/controller/announcement_controller/announcement_controller.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/controller/media_interaction_controller/media_interaction_controller.dart';
import 'package:repathy/src/controller/pain_controller/pain_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/announcement_model/announcement_model.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/util/enum/page_enum.dart';

class PatientHomePage extends ConsumerWidget {
  const PatientHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final mediaModelList = ref.watch(getMediaListProvider(includeInteractions: true));
    final announcementsResultList = ref.watch(getAnnouncementListProvider);

    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TherapistCardForPatients(
              userModel: user!,
              leftPadding: 16,
              topPadding: 16,
              rightPadding: 8,
              bottomPadding: 16,
            ),
            announcementsResultList.when(
              data: (final ResultModel<List<AnnouncementModel>> announcements) {
                final announcementList = announcements.data;
                final finalVowel = announcementList?.length == 1 ? 'e' : 'i';

                return SectionCard(
                  title: 'Comunicazioni',
                  description: '${announcementList?.length ?? '0'} comuncazion$finalVowel',
                  index: 1,
                  subPage: PageEnum.notifications,
                  onAddCallback: () {},
                  widthScale: 1,
                  leftPadding: 16,
                  topPadding: 4,
                  rightPadding: 8,
                  bottomPadding: 16,
                  backgroundImageScale: 9,
                  imageBottomPadding: 0,
                  backgroundImage: 'assets/image/announcement.png',
                );
              },
              error: (error, stackTrace) => SizedBox.shrink(),
              loading: () => Center(child: CircularProgressIndicator()),
            ),
            mediaModelList.when(
              data: (final ResultModel<List<MediaModel>> mediaModelListResult) {
                final mediaModelList = mediaModelListResult.data;
                final mediaModelLength = mediaModelList?.length;
                final finalVowel = mediaModelLength == 1 ? 'io' : 'i';
                final description = mediaModelLength == 0 ? 'Nessun esercizio' : '$mediaModelLength eserciz$finalVowel';
                final mediaInteractions = ref.read(mediaInteractionControllerProvider.notifier).getAllInteractionsFromAMediaList(mediaModelList);
                final lastMediaInteraction = ref.read(mediaInteractionControllerProvider.notifier).findClosestInteraction(mediaInteractions);
                final lastInteractionId = lastMediaInteraction?.mediaId;
                final lastMediaModel = ref.read(mediaInteractionControllerProvider.notifier).findMediaModelById(mediaModelList, lastInteractionId);
                final lastMediaModelPain = lastMediaModel?.painEnum.first;
                final lastMediaPainPath = ref.read(painControllerProvider.notifier).extractPainPathFromPainEnum(lastMediaModelPain);
                final interactionDescription = lastMediaModel?.id != null ? 'il video' : 'Nessun video';
                debugPrint('View: Last media model is title: ${lastMediaModel?.title} and id: ${lastMediaModel?.id} and asset is $lastMediaPainPath');
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SectionCard(
                      title: 'Esercizi',
                      description: description,
                      index: 2,
                      subPage: PageEnum.none,
                      onAddCallback: () {},
                      leftPadding: 16,
                      rightPadding: 4,
                      widthScale: 0.4,
                      backgroundImageScale: 13,
                      backgroundImage: 'assets/image/library.png',
                    ),
                    SectionCard(
                      title: 'Continua',
                      description: interactionDescription,
                      index: 2,
                      subPage: PageEnum.videoDetail,
                      conditionCallBack: () => lastMediaModel?.id != null,
                      onAddCallback: () {
                        if (lastMediaModel != null) ref.read(mediaControllerProvider.notifier).updateState(lastMediaModel);
                      },
                      leftPadding: 16,
                      rightPadding: 4,
                      widthScale: 0.4,
                      backgroundImageScale: 11,
                      backgroundImage: lastMediaPainPath ?? 'assets/image/continue_video.png',
                    ),
                  ],
                );
              },
              error: (error, stackTrace) => SizedBox.shrink(),
              loading: () => CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
