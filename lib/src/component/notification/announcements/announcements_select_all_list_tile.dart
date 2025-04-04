import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class AnnouncementsSelectAllListTile extends ConsumerWidget {
  const AnnouncementsSelectAllListTile({super.key, required this.patients});

  final List<UserModel> patients;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      tileColor: RepathyStyle.backgroundColor,
      title: Text('Seleziona tutti'),
      trailing: IconButton(
        icon: Container(
          width: RepathyStyle.standardIconSize,
          height: RepathyStyle.standardIconSize,
          decoration: BoxDecoration(
            color: ref.read(filteredPatientsForSelectionListProvider(patients).notifier).areAllUsersSelected() == true
                ? RepathyStyle.primaryColor
                : RepathyStyle.backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: RepathyStyle.primaryColor, width: 2.0),
          ),
          child: Center(
            child: Icon(
              ref.read(filteredPatientsForSelectionListProvider(patients).notifier).areAllUsersSelected() == true ? Icons.check : null,
              size: RepathyStyle.standardIconSize - 8, // Adjust size to fit within the border
              color: RepathyStyle.backgroundColor,
            ),
          ),
        ),
        onPressed: () => ref.read(filteredPatientsForSelectionListProvider(patients).notifier).decideToSelectOrDeselectAllUsers(),
      ),
    );
  }
}
