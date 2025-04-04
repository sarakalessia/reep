import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/exercises_add_button.dart';
import 'package:repathy/src/component/media/media_library_body.dart';
import 'package:repathy/src/component/media/media_options_bottom_sheet.dart';
import 'package:repathy/src/component/search_bar/search_bar.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/util/enum/media_format_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class TherapistLibraryPage extends ConsumerStatefulWidget {
  const TherapistLibraryPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TherapistLibraryPageState();
}

class _TherapistLibraryPageState extends ConsumerState<TherapistLibraryPage> {
  @override
  Widget build(BuildContext context) {
    final mediaModelList = ref.watch(filteredMediaListProvider(includeInteractions: true));
    final currentPatient = ref.watch(currentPatientProvider);
    final currentMediaFormat = ref.watch(mediaFormatFilterProvider);
    final title = currentMediaFormat == MediaFormatEnum.pdf ? 'PDF' : 'Video';

    return Flexible(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: Align(alignment: Alignment.centerLeft, child: PageTitleText(title: 'Libreria')),
                  ),
                  if (currentPatient == null && currentMediaFormat == MediaFormatEnum.unknown) ...[
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Align(alignment: Alignment.centerLeft, child: PageDescriptionText(title: 'Tutti i video e pdf creati da te')),
                    ),
                  ],
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (currentMediaFormat != MediaFormatEnum.unknown) ...[
                            Row(
                              children: [
                                PageDescriptionText(title: title),
                                SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => ref.invalidate(mediaFormatFilterProvider),
                                  child: Icon(Icons.close, size: 18, color: RepathyStyle.errorColor),
                                ),
                              ],
                            ),
                            SizedBox(width: 16),
                          ],
                          if (currentPatient != null) ...[
                            Row(
                              children: [
                                PageDescriptionText(title: '${currentPatient.name}'),
                                SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => ref.read(currentPatientProvider.notifier).clearUser(),
                                  child: Icon(Icons.close, size: 18, color: RepathyStyle.errorColor),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: ExercisesAddButton(
                  function: () {
                    return showModalBottomSheet(
                      context: context,
                      builder: (context) => MediaOptionsBottomSheet(),
                    );
                  },
                ),
              ),
            ],
          ),
          CustomSearchBar(hintText: 'Cerca per titolo'),
          mediaModelList.when(
              data: (data) {
                final List<MediaModel> mediaModelList = data;

                if (mediaModelList.isEmpty) return PageDescriptionText(title: 'Non ci sono video');

                return MediaLibraryBody(mediaModelList: mediaModelList);
              },
              error: (error, stackTrace) => PageDescriptionText(title: 'Non ci sono video'),
              loading: () => CircularProgressIndicator()),
        ],
      ),
    );
  }
}
