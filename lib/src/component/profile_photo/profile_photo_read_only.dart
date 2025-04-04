import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/profile_image_controller/profile_image_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class ProfilePhotoReadOnly extends ConsumerWidget {
  const ProfilePhotoReadOnly({
    super.key,
    required this.image,
    this.radius = 40,
    this.hasGradient = true,
    this.otherUser,
  });

  final NetworkImage image;
  final double radius;
  final bool hasGradient;
  final UserModel? otherUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final File? imageController = ref.watch(imageFileControllerProvider(isCover: false));
    final UserModel? currentUser = ref.watch(userControllerProvider);
    final UserModel? chosenUser = otherUser ?? currentUser;
    final String nameInitial = chosenUser?.name?.substring(0, 1).toUpperCase() ?? '';
    final String lastNameInitial = chosenUser?.lastName?.substring(0, 1).toUpperCase() ?? '';

    return Container(
      padding: const EdgeInsets.all(4.0), // Padding for the border
      decoration: BoxDecoration(
        gradient: hasGradient ? RepathyStyle.secondaryGradient : null,
        shape: BoxShape.circle,
      ),
      child: imageController == null
          ? (image.url.isNotEmpty
              ? CircleAvatar(
                  radius: radius,
                  backgroundColor: RepathyStyle.backgroundColor,
                  backgroundImage: image,
                )
              : CircleAvatar(
                  radius: radius,
                  child: Text('$nameInitial$lastNameInitial',
                      style: TextStyle(
                        fontSize: radius < 40 ? RepathyStyle.standardTextSize : RepathyStyle.giantTextSize,
                        color: RepathyStyle.darkTextColor,
                      )),
                ))
          : CircleAvatar(
              radius: radius,
              backgroundImage: FileImage(imageController),
            ),
    );
  }
}
