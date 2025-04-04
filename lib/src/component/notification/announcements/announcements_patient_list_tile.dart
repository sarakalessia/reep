import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/profile_photo/profile_photo_read_only.dart';
import 'package:repathy/src/controller/patient_controller/patient_controller.dart';
import 'package:repathy/src/model/component_models/user_component_model/user_component_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class AnnouncementsPatientListTile extends ConsumerStatefulWidget {
  const AnnouncementsPatientListTile({
    super.key,
    required this.user,
    required this.users,
    required this.index,
    this.isMultiSelect = true,
  });

  final UserComponentModel user;
  final List<UserModel> users;
  final int index;
  final bool isMultiSelect;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnnouncementsPatientListTileState();
}

class _AnnouncementsPatientListTileState extends ConsumerState<AnnouncementsPatientListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: RepathyStyle.backgroundColor,
      leading: ProfilePhotoReadOnly(
        image: NetworkImage(widget.user.userModel!.profileImage ?? ''),
        radius: 16,
        otherUser: widget.user.userModel!,
      ),
      title: Text(widget.user.userModel!.name ?? 'Senza nome'),
      trailing: IconButton(
        icon: Container(
          width: RepathyStyle.standardIconSize,
          height: RepathyStyle.standardIconSize,
          decoration: BoxDecoration(
            color: widget.user.isSelected == true ? RepathyStyle.primaryColor : RepathyStyle.backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: RepathyStyle.primaryColor, width: 2.0),
          ),
          child: Center(
            child: Icon(
              widget.user.isSelected == true ? Icons.check : null,
              size: RepathyStyle.standardIconSize - 8, // Adjust size to fit within the border
              color: RepathyStyle.backgroundColor,
            ),
          ),
        ),
        onPressed: () {
          widget.isMultiSelect
              ? ref.read(filteredPatientsForSelectionListProvider(widget.users).notifier).selectUser(widget.index)
              : ref.read(filteredPatientsForSelectionListProvider(widget.users).notifier).selectUserAndDeselectOthers(widget.index);
        },
      ),
    );
  }
}
