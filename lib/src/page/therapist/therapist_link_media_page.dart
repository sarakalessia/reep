import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/patient_list/patient_list_selection_body.dart';
import 'package:repathy/src/component/search_bar/search_bar.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/controller/bottom_nav_bar_controller/bottom_nav_bar_controller.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/util/enum/page_enum.dart';

class TherapistLinkMediaPage extends ConsumerStatefulWidget {
  const TherapistLinkMediaPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TherapistLinkMediaPageState();
}

class _TherapistLinkMediaPageState extends ConsumerState<TherapistLinkMediaPage> {
  @override
  Widget build(BuildContext context) {
    final filteredPatientsForSelection = ref.watch(asyncFilteredPatientsProvider(excludeTransferedPatients: false));
    final currentMedia = ref.watch(mediaControllerProvider);

    return Flexible(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
            child: Align(alignment: Alignment.centerLeft, child: PageTitleText(title: 'Pazienti')),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Align(
                alignment: Alignment.centerLeft, child: PageDescriptionText(title: 'Assegna il video a uno dei tuoi pazienti')),
          ),
          CustomSearchBar(bottomPadding: 12),
          filteredPatientsForSelection.when(
            data: (final dataResult) {
              final data = dataResult.data;
              if (data == null) return Text('Non ci sono pazienti');
              return data.isEmpty
                  ? Text('Non ci sono pazienti')
                  : Column(
                      children: [
                        PrimaryButton(
                          text: 'Assegna a tutti',
                          onPressed: () => ref.read(filteredPatientsForSelectionListProvider(data).notifier).selectAllUsers(),
                          isRounded: false,
                        ),
                        PatientListPageSelectionBody(userModelList: data),
                        PrimaryButton(
                          text: 'Assegna',
                          onPressed: () async {
                            List<String> userIds =
                                await ref.read(userControllerProvider.notifier).convertUserModelListToUserIdList(data);
                            if (userIds.isEmpty) return;
                            await ref
                                .read(mediaControllerProvider.notifier)
                                .linkMediaToPatients(mediaId: currentMedia?.id ?? '', patientIds: userIds);
                            ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 2, subPage: PageEnum.none);
                            if (context.mounted) ref.read(bottomNavBarVisibilityProvider(context).notifier).toggleVisibility();
                            ref.invalidate(mediaControllerProvider);
                          },
                        ),
                      ],
                    );
            },
            error: (error, stackTrace) => Text('Non ci sono pazienti'),
            loading: () => CircularProgressIndicator(),
          ),
          TextButton(
            onPressed: () {
              ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 2, subPage: PageEnum.none);
              ref.read(bottomNavBarVisibilityProvider(context).notifier).toggleVisibility();
              ref.invalidate(mediaControllerProvider);
            },
            child: PageDescriptionText(title: 'Salta'),
          ),
        ],
      ),
    );
  }
}
