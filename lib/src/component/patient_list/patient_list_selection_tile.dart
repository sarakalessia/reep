import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class PatientListPageSelectionTile extends ConsumerStatefulWidget {
  const PatientListPageSelectionTile({super.key, required this.index, required this.userModelList});

  final List<UserModel> userModelList;
  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PatientListPageSelectionTileState();
}

class _PatientListPageSelectionTileState extends ConsumerState<PatientListPageSelectionTile> {
  @override
  Widget build(BuildContext context) {
    final filteredPatientsForSelectionList = ref.watch(filteredPatientsForSelectionListProvider(widget.userModelList));

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: ListTile(
        tileColor: RepathyStyle.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RepathyStyle.standardRadius),
          side: BorderSide(color: RepathyStyle.borderColor, width: 1.5),
        ),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 0, 16),
          child: Text(
              '${filteredPatientsForSelectionList[widget.index].userModel?.name ?? ''} ${filteredPatientsForSelectionList[widget.index].userModel?.lastName ?? ''}'),
        ),
        trailing: IconButton(
          icon: Container(
            width: RepathyStyle.standardIconSize,
            height: RepathyStyle.standardIconSize,
            decoration: BoxDecoration(
              color: filteredPatientsForSelectionList[widget.index].isSelected == true ? RepathyStyle.primaryColor : RepathyStyle.backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: RepathyStyle.primaryColor,
                width: 1.0, // Lighter border width
              ),
            ),
            child: Center(
              child: Icon(
                filteredPatientsForSelectionList[widget.index].isSelected == true ? Icons.check : null,
                size: RepathyStyle.standardIconSize - 4, // Adjust size to fit within the border
                color: RepathyStyle.backgroundColor,
              ),
            ),
          ),
          onPressed: () => ref.read(filteredPatientsForSelectionListProvider(widget.userModelList).notifier).selectUser(widget.index),
        ),
      ),
    );
  }
}
