import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/patient_list/patient_transfer_bottom_sheet.dart';
import 'package:repathy/src/component/patient_list/patient_unlink_bottom_sheet.dart';
import 'package:repathy/src/component/profile_photo/profile_photo_read_only.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class PatientListPageTile extends ConsumerStatefulWidget {
  const PatientListPageTile({super.key, required this.patientUserModel});

  final UserModel patientUserModel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PatientListPageTileState();
}

class _PatientListPageTileState extends ConsumerState<PatientListPageTile> {
  int? age;

  @override
  void initState() {
    _calculateAgeFromBirthDate();
    super.initState();
  }

  _calculateAgeFromBirthDate() {
    if (widget.patientUserModel.birthDate != null) {
      final birthDate = widget.patientUserModel.birthDate;
      final currentDate = DateTime.now();
      age = currentDate.year - birthDate!.year;
      if (currentDate.month < birthDate.month) {
        age = age! - 1;
      } else if (currentDate.month == birthDate.month) {
        if (currentDate.day < birthDate.day) {
          age = age! - 1;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(currentPatientProvider);
    final therapist = ref.read(userControllerProvider);
    final substituteTherapist = widget.patientUserModel.substituteTherapistId;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
        tileColor: RepathyStyle.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RepathyStyle.standardRadius),
          side: BorderSide(color: RepathyStyle.borderColor, width: 1.5),
        ),
        leading: ProfilePhotoReadOnly(
          image: NetworkImage(widget.patientUserModel.profileImage ?? ''),
          radius: RepathyStyle.smallIconSize,
          otherUser: widget.patientUserModel,
        ),
        title: Padding(padding: const EdgeInsets.only(left: 0), child: Text('${widget.patientUserModel.name} ${widget.patientUserModel.lastName}')),
        subtitle: Padding(padding: const EdgeInsets.only(left: 0), child: Text('$age anni')),
        onTap: () {
          ref.read(currentPatientProvider.notifier).selectUser(widget.patientUserModel);
          ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 0, subPage: PageEnum.patientDetail);
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (substituteTherapist != null && substituteTherapist.isNotEmpty) ...[
              IconButton(
                icon: Icon(
                  Icons.reply_all_rounded,
                  size: RepathyStyle.standardIconSize,
                  color: RepathyStyle.darkTextColor,
                ),
                onPressed: () {
                  if (therapist == null) return;
                  _showTransferBottomSheet(context, widget.patientUserModel, therapist);
                },
              ),
            ],
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                size: RepathyStyle.standardIconSize,
                color: RepathyStyle.darkTextColor,
              ),
              onPressed: () {
                if (therapist == null) return;
                _showBottomSheet(context, widget.patientUserModel, therapist);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, UserModel patientUserModel, UserModel therapistModel) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) => PatientUnlinkOrDeleteBottomSheet(user: patientUserModel, therapist: therapistModel),
    );
  }

  void _showTransferBottomSheet(BuildContext context, UserModel patientUserModel, UserModel therapistModel) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => PatientTransferBottomSheet(user: patientUserModel, therapist: therapistModel),
    );
  }
}
