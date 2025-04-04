import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/notification/announcements/announcements_patient_list_tile.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class PatientListPageSelectionBody extends ConsumerStatefulWidget {
  const PatientListPageSelectionBody({
    super.key,
    required this.userModelList,
    this.height = 280,
    this.isMultiSelect = true,
  });

  final List<UserModel> userModelList;
  final double height;
  final bool isMultiSelect;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PatientListPageSelectionBodyState();
}

class _PatientListPageSelectionBodyState extends ConsumerState<PatientListPageSelectionBody> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userComponentModelList = ref.watch(filteredPatientsForSelectionListProvider(widget.userModelList));

    return SizedBox(
      height: widget.height,
      child: RawScrollbar(
        controller: scrollController,
        thumbVisibility: true,
        thumbColor: RepathyStyle.primaryColor,
        radius: Radius.circular(RepathyStyle.lightRadius),
        thickness: 3,
        child: ListView.builder(
          controller: scrollController,
          itemCount: userComponentModelList.length,
          itemBuilder: (context, index) {
            debugPrint('View: userComponentModelList: ${userComponentModelList.length}');
            return AnnouncementsPatientListTile(
              user: userComponentModelList[index],
              users: widget.userModelList,
              index: index,
              isMultiSelect: widget.isMultiSelect,
            );
          },
        ),
      ),
    );
  }
}
