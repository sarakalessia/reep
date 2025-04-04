import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/patient_list/patient_unlink_bottom_sheet.dart';
import 'package:repathy/src/component/profile_photo/profile_photo_read_only.dart';
import 'package:repathy/src/controller/profile_image_controller/profile_image_controller.dart';
import 'package:repathy/src/controller/studio_controller/studio_controller.dart';
import 'package:repathy/src/controller/therapist_controller/therapist_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class TherapistPublicProfile extends ConsumerStatefulWidget {
  const TherapistPublicProfile({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TherapistPublicProfileState();
}

class _TherapistPublicProfileState extends ConsumerState<TherapistPublicProfile> {
  @override
  Widget build(BuildContext context) {
    final therapist = ref.watch(currentTherapistProvider);
    final currentUser = ref.watch(userControllerProvider);
    final image = ref.watch(imageFromCurrentTherapistProvider);
    final currentUserStudio = ref.watch(getStudioByUserIdProvider(currentUser));

    return Flexible(
        child: SingleChildScrollView(
      child: Column(
        children: [
          image.when(
            data: (NetworkImage image) => ProfilePhotoReadOnly(image: image, otherUser: therapist),
            error: (e, st) => const Icon(Icons.menu),
            loading: () => const CircularProgressIndicator(),
          ),
          SizedBox(height: 16),
          if (therapist?.description != null) _buildReadOnlyField(therapist?.description ?? '', isDescription: true),
          _buildReadOnlyField(therapist?.name ?? ''),
          currentUserStudio.when(
            data: (final data) {
              final studio = data.data;
              return _buildReadOnlyField(studio?.studioName ?? '');
            },
            error: (error, stackTrace) => Text(''),
            loading: () => CircularProgressIndicator(),
          ),
          if (therapist?.addressString != null) _buildReadOnlyField(therapist?.addressString ?? ''),
          _buildReadOnlyField(therapist?.email ?? ''),
          if (therapist?.phoneNumber != null) _buildReadOnlyField(therapist?.phoneNumber ?? ''),
          if (therapist?.id != null && currentUser?.id != null) _renderRemoveLinkDialog(context, currentUser!, therapist!),
        ],
      ),
    ));
  }

  Widget _buildReadOnlyField(String? text, {bool isDescription = false}) {
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.only(left: 4),
        height: isDescription ? 120 : 48,
        width: double.infinity,
        decoration: BoxDecoration(
          color: RepathyStyle.backgroundColor,
          borderRadius: BorderRadius.circular(32.0),
          border: Border.all(
            color: RepathyStyle.inputFieldHintTextColor,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isDescription ? _buildScrollableVersion(text) : _buildStandardVersion(text),
        ),
      ),
    );
  }

  Widget _buildScrollableVersion(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        child: Text(
          text,
          style: TextStyle(
            fontSize: RepathyStyle.standardTextSize,
            fontWeight: RepathyStyle.lightFontWeight,
          ),
        ),
      ),
    );
  }

  Widget _buildStandardVersion(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: RepathyStyle.standardTextSize,
          fontWeight: RepathyStyle.lightFontWeight,
        ),
      ),
    );
  }

  Widget _renderRemoveLinkDialog(BuildContext context, UserModel patientModel, UserModel therapistModel) {
    return TextButton(
      onPressed: () => _showBottomSheet(context, patientModel, therapistModel),
      child: Text('Togliere il collegamento'),
    );
  }

  void _showBottomSheet(BuildContext context, UserModel patientUserModel, UserModel therapistModel) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => PatientUnlinkOrDeleteBottomSheet(user: patientUserModel, therapist: therapistModel),
    );
  }
}
