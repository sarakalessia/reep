import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/notification/announcements/announcements_patient_list_tile.dart';
import 'package:repathy/src/component/notification/announcements/announcements_select_all_list_tile.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class AnnouncementsPatientList extends ConsumerStatefulWidget {
  const AnnouncementsPatientList({super.key, required this.patients});

  final List<UserModel> patients;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnnouncementsPatientListState();
}

class _AnnouncementsPatientListState extends ConsumerState<AnnouncementsPatientList> {
  @override
  Widget build(BuildContext context) {
    final filteredPatients = ref.watch(filteredPatientsForSelectionListProvider(widget.patients));
    final isOpen = ref.watch(isPatientListOpenProvider);
    ref.watch(selectedPatientsProvider(widget.patients));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.fromLTRB(4, 16, 8, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RepathyStyle.roundedRadius),
        border: Border.all(color: RepathyStyle.inputFieldHintTextColor, width: 1),
      ),
      height: isOpen ? 300 : 85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 0, 4),
                child: Text(
                  'Seleziona i pazienti:',
                  style: TextStyle(fontSize: RepathyStyle.smallTextSize),
                ),
              ),
              IconButton(
                icon: Icon(
                  isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: RepathyStyle.primaryColor,
                ),
                onPressed: () => ref.read(isPatientListOpenProvider.notifier).toggleState(),
              ),
            ],
          ),
          isOpen ? AnnouncementsSelectAllListTile(patients: widget.patients) : SizedBox.shrink(),
          isOpen
              ? Expanded(
                  child: RawScrollbar(
                    thumbVisibility: true,
                    thumbColor: RepathyStyle.primaryColor,
                    radius: Radius.circular(RepathyStyle.lightRadius),
                    thickness: 3,
                    child: ListView.builder(
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        final patient = filteredPatients[index];
                        return AnnouncementsPatientListTile(
                          user: patient,
                          users: widget.patients,
                          index: index,
                        );
                      },
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
