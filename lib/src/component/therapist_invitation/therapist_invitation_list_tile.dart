import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/profile_photo/profile_photo_read_only.dart';
import 'package:repathy/src/controller/studio_controller/studio_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class TherapistInvitationListTile extends ConsumerWidget {
  const TherapistInvitationListTile({
    super.key,
    required this.userModel,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 8,
  });

  final UserModel userModel;
  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? selectedUser = ref.watch(selectedUserProvider);
    final therapistStudio = ref.watch(getStudioByUserIdProvider(userModel));

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: ListTile(
        tileColor: RepathyStyle.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RepathyStyle.standardRadius),
          side: BorderSide(color: RepathyStyle.borderColor, width: 1.5),
        ),
        leading: ProfilePhotoReadOnly(
          image: NetworkImage(userModel.profileImage ?? ''),
          radius: RepathyStyle.standardIconSize,
          otherUser: userModel,
        ),
        title: Text(userModel.name ?? ''),
        subtitle: therapistStudio.when(
          data: (final data) {
            final studio = data.data;
            return Text(studio?.studioName ?? '');
          },
          error: (error, stackTrace) => null,
          loading: () => Center(child: CircularProgressIndicator()),
        ),
        trailing: IconButton(
          icon: Icon(
            selectedUser?.id == userModel.id ? Icons.check_circle : Icons.circle_outlined,
            size: RepathyStyle.standardIconSize,
            color: RepathyStyle.primaryColor,
          ),
          onPressed: () => ref.read(selectedUserProvider.notifier).selectUser(userModel),
        ),
      ),
    );
  }
}
