import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/therapist_home/therapist_card.dart';
import 'package:repathy/src/component/therapist_home/section_card.dart';
import 'package:repathy/src/component/media/media_options_bottom_sheet.dart';
import 'package:repathy/src/component/notification/announcements/announcements_bottom_sheet.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class TherapistHomePage extends ConsumerWidget {
  const TherapistHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);
    final filteredPatientsForSelection = ref.watch(asyncFilteredPatientsProvider(excludeTransferedPatients: false));
    final decidePatientPlural = user!.patientId.length == 1 ? 'e' : 'i';
    final decideAnnouncementPlural = user.announcementIdList.length == 1 ? 'e' : 'i';

    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          children: [
            TherapistCard(
              userModel: user,
              leftPadding: 16,
              topPadding: 16,
              rightPadding: 8,
              bottomPadding: 16,
            ),
            SectionCard(
              backgroundImageScale: 10,
              backgroundImage: 'assets/image/patient.png',
              title: AppLocalizations.of(context)!.patientSectionTitle,
              description: '${user.patientId.length.toString()} pazient$decidePatientPlural',
              onAddCallback: () {},
              index: 0,
              subPage: PageEnum.none,
              widthScale: 1,
              leftPadding: 16,
              topPadding: 4,
              rightPadding: 8,
              bottomPadding: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                filteredPatientsForSelection.when(
                  data: (result) {                    
                    return SectionCard(
                      backgroundImageScale: 10,
                      backgroundImage: 'assets/image/announcement.png',
                      title: AppLocalizations.of(context)!.communcationSectionTitle,
                      description: '${user.announcementIdList.length.toString()} comunicazion$decideAnnouncementPlural',
                      onAddCallback: () {
                        final data = result.data;
                        if (data == null) return null;
                        return showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(RepathyStyle.roundedRadius),
                                topRight: Radius.circular(RepathyStyle.roundedRadius),
                              ),
                              child: Container(
                                color: RepathyStyle.backgroundColor,
                                height: MediaQuery.of(context).size.height * 0.8,
                                child: AnnouncementsBottomSheet(patients: data),
                              ),
                            );
                          },
                        );
                      },
                      index: 1,
                      subPage: PageEnum.notifications,
                      leftPadding: 16,
                      // rightPadding: 4,
                    );
                  },
                  error: (error, stackTrace) => SizedBox.shrink(),
                  loading: () => CircularProgressIndicator(),
                ),
                SectionCard(
                  title: 'Libreria',
                  description: '${user.mediaIdList.length.toString()} video',
                  onAddCallback: () => showModalBottomSheet(
                    context: context,
                    builder: (context) => MediaOptionsBottomSheet(),
                  ),
                  index: 2,
                  subPage: PageEnum.none,
                  rightPadding: 8,
                  // leftPadding: 8,
                  backgroundImage: 'assets/image/library.png',
                  backgroundImageScale: 14,
                  imageTopPadding: 34,
                  imageBottomPadding: 12,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
