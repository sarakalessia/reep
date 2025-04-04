import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/generic_add_button.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/patient_list/patient_creation_bottom_sheet.dart';
import 'package:repathy/src/component/patient_list/patient_list_body.dart';
import 'package:repathy/src/component/search_bar/search_bar.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/util/enum/element_size_enum.dart';
import 'package:repathy/src/util/enum/page_enum.dart';

class PatientListPage extends ConsumerStatefulWidget {
  const PatientListPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PatientListPageState();
}

class _PatientListPageState extends ConsumerState<PatientListPage> {
  @override
  Widget build(BuildContext context) {
    final asyncFilteredPatients = ref.watch(asyncFilteredPatientsProvider(includeTemporaryPatients: true));

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
                    child: Align(alignment: Alignment.centerLeft, child: PageTitleText(title: 'Pazienti')),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Align(alignment: Alignment.centerLeft, child: PageDescriptionText(title: 'Pazienti collegati a te')),
                  ),
                ],
              ),
              GenericAddButton(
                rightPadding: 14,
                topPadding: 0,
                bottomPadding: 0,
                function: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) => PatientCreationBottomSheet(),
                  );
                },
              ),
            ],
          ),
          CustomSearchBar(bottomPadding: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PrimaryButton(
                leftPadding: 0,
                topPadding: 0,
                bottomPadding: 0,
                isRounded: false,
                size: ElementSize.large,
                text: 'Trasferimento',
                onPressed: () => ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 0, subPage: PageEnum.patientTransfer),
              ),
            ],
          ),
          SizedBox(height: 16),
          RefreshIndicator.adaptive(
            onRefresh: () async => ref.read(asyncFilteredPatientsProvider(includeTemporaryPatients: true)),
            child: asyncFilteredPatients.when(
              data: (final patients) {
                final data = patients.data;
                if (data == null) return _returnEmptyList();
                return data.isNotEmpty ? PatientListPageBody(userList: data) : _returnEmptyList();
              },
              error: (error, stackTrace) => _returnEmptyList(),
              loading: () => Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _returnEmptyList() => Center(child: PageDescriptionText(title: 'Non ci sono pazienti'));
}
