import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/patient_list/patient_list_selection_body.dart';
import 'package:repathy/src/component/text/tile_title_text.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';

class AnnouncementsPatientsDialog extends ConsumerStatefulWidget {
  const AnnouncementsPatientsDialog({super.key, required this.patients});

  final List<UserModel> patients;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnnouncementsPatientsDialogState();
}

class _AnnouncementsPatientsDialogState extends ConsumerState<AnnouncementsPatientsDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: TileTitleText(title: 'Seleziona i pazienti'),
            ),
            PatientListPageSelectionBody(userModelList: widget.patients),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Chiudi')),
          ],
        ),
      ));
  }
}
