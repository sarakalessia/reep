import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:repathy/src/component/media/media_options_bottom_sheet.dart';
import 'package:repathy/src/component/patient_details/patient_details_card.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/util/enum/media_format_enum.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class PatientDetailsPage extends ConsumerWidget {
  const PatientDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPatient = ref.watch(currentPatientProvider);
    final mediaModelList = ref.watch(getMediaListProvider(targetUser: currentPatient, includeInteractions: true));
    final fullName = '${currentPatient!.name} ${currentPatient.lastName}';
    final patientAge = currentPatient.birthDate != null ? '${DateTime.now().difference(currentPatient.birthDate!).inDays ~/ 365} anni' : '';

    return Flexible(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: Align(alignment: Alignment.centerLeft, child: PageTitleText(title: fullName)),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Align(alignment: Alignment.centerLeft, child: PageDescriptionText(title: patientAge)),
          ),
          Row(
            children: [
              PatientDetailsCard(
                widthScale: 0.41,
                leftPadding: 10,
                topPadding: 20,
                rightPadding: 10,
                bottomPadding: 20,
                title: 'PDF',
                function: () => showModalBottomSheet(context: context, builder: (context) => MediaOptionsBottomSheet()),
                index: 2,
                subPage: PageEnum.none,
                mediaFormatEnum: MediaFormatEnum.pdf,
              ),
              PatientDetailsCard(
                widthScale: 0.41,
                leftPadding: 10,
                topPadding: 20,
                rightPadding: 10,
                bottomPadding: 20,
                title: 'Video',
                function: () => showModalBottomSheet(context: context, builder: (context) => MediaOptionsBottomSheet()),
                index: 2,
                subPage: PageEnum.none,
                mediaFormatEnum: MediaFormatEnum.mp4,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 0, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Storico',
                style: const TextStyle(
                  fontSize: RepathyStyle.largeTextSize,
                  color: RepathyStyle.defaultTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            height: MediaQuery.sizeOf(context).height * 0.3,
            child: mediaModelList.when(
              data: (mediaModelListResult) {
                final mediaModelListData = mediaModelListResult.data;

                if (mediaModelListData == null || mediaModelListData.isEmpty) return const Center(child: Text('Non ci sono video'));

                debugPrint('View: mediaModelListResult: $mediaModelListResult is not null nor empty');

                return ListView.builder(
                  itemCount: mediaModelListData.length,
                  itemBuilder: (context, index) {
                    final mediaModel = mediaModelListData[index];
                    final mediaInteractions =
                        mediaModel.mediaInteractions.where((interaction) => interaction.patientId == currentPatient.id).toList();

                    if (mediaInteractions.isEmpty) return const SizedBox.shrink();

                    return Column(
                      children: mediaInteractions.map((interaction) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                          child: ListTile(
                            tileColor: RepathyStyle.backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(RepathyStyle.standardRadius),
                              side: BorderSide(color: RepathyStyle.borderColor, width: 1.5),
                            ),
                            title: Text('${currentPatient.name} ${currentPatient.lastName} ha riprodotto'),
                            subtitle: Text('${mediaModel.title}'),
                            trailing: Text(DateFormat('dd/MM/yyyy').format(interaction.openedAt!)),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
