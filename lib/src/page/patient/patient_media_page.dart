import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/media/media_library_body.dart';
import 'package:repathy/src/component/search_bar/search_bar.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/controller/pain_controller/pain_controller.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/util/constant/pain_list_const.dart';
import 'package:repathy/src/util/enum/pain_enum.dart';

class PatientMediaPage extends ConsumerStatefulWidget {
  const PatientMediaPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PatientMediaPageState();
}

class _PatientMediaPageState extends ConsumerState<PatientMediaPage> {
  @override
  Widget build(BuildContext context) {
    final mediaModelList = ref.watch(filteredMediaListProvider(includeInteractions: true));
    final PainEnum currentPain = ref.watch(currentPainControllerProvider);
    final String? painSubtitle = painTitles[currentPain];

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
                    child: Align(alignment: Alignment.centerLeft, child: PageTitleText(title: 'Video degli esercizi')),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Align(alignment: Alignment.centerLeft, child: PageDescriptionText(title: painSubtitle ?? 'Secgli un video')),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(child: CustomSearchBar(hintText: 'Cerca')),
          mediaModelList.when(
            data: (List<MediaModel> data) {
              final mediaModelList = data;
              if (mediaModelList.isEmpty) return PageDescriptionText(title: 'Non ci sono video');
              return MediaLibraryBody(mediaModelList: mediaModelList);
            },
            error: (error, stackTrace) => PageDescriptionText(title: 'Non ci sono video'),
            loading: () => CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
