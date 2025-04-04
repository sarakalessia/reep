import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/generic_add_button.dart';
import 'package:repathy/src/component/notification/announcements/announcements_bottom_sheet.dart';
import 'package:repathy/src/component/notification/announcements/announcements_card.dart';
import 'package:repathy/src/controller/announcement_controller/announcement_controller.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/util/enum/element_size_enum.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class AnnouncementsList extends ConsumerWidget {
  const AnnouncementsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsResultList = ref.watch(getAnnouncementListProvider);
    final filteredPatientsForSelection = ref.watch(asyncFilteredPatientsProvider(includeTemporaryPatients: true));
    final user = ref.watch(userControllerProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (user!.role == RoleEnum.therapist) ...[
                filteredPatientsForSelection.when(
                  data: (data) {
                    final patients = data.data;
                    if (patients == null) return Text('');
                    return GenericAddButton(
                      function: () => showModalBottomSheet(
                        context: context,
                        builder: (context) => ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(RepathyStyle.roundedRadius),
                            topRight: Radius.circular(RepathyStyle.roundedRadius),
                          ),
                          child: Container(
                            color: RepathyStyle.backgroundColor,
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: AnnouncementsBottomSheet(patients: patients),
                          ),
                        ),
                        isScrollControlled: true,
                        isDismissible: true,
                      ),
                      size: ElementSize.small,
                    );
                  },
                  error: (error, stackTrace) => SizedBox.shrink(),
                  loading: () => CircularProgressIndicator(),
                ),
              ],
            ],
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 350,
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(getAnnouncementListProvider.future),
              child: announcementsResultList.when(
                data: (final announcements) {
                  final announcementList = announcements.data;
                  if (announcementList == null) return Center(child: Text('Nessuno annuncio trovato'));
                  return ListView.builder(
                    itemCount: announcementList.length,
                    itemBuilder: (context, index) => AnnouncementsCard(announcementModel: announcementList[index]),
                  );
                },
                error: (error, stackTrace) => Center(child: Text('Nessuno annuncio trovato')),
                loading: () => Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
