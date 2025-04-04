import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/profile_photo/profile_photo_bottom_sheet.dart';
import 'package:repathy/src/controller/profile_image_controller/profile_image_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class ProfilePhoto extends ConsumerWidget {
  const ProfilePhoto({super.key, required this.image});

  final NetworkImage image;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final File? imageFileController = ref.watch(imageFileControllerProvider(isCover: false));
    final UserModel? currentUser = ref.watch(userControllerProvider);
    final String nameInitial = currentUser?.name?.substring(0, 1).toUpperCase() ?? '';
    final String lastNameInitial = currentUser?.lastName?.substring(0, 1).toUpperCase() ?? '';

    return GestureDetector(
      onTap: () async {
        showModalBottomSheet(
          context: context,
          builder: (context) => ProfilePhotoBottomSheet(user: currentUser!),
        );
      },
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                child: Container(
                  padding: const EdgeInsets.all(4.0), // Padding for the border
                  decoration: const BoxDecoration(
                    gradient: RepathyStyle.secondaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: imageFileController == null
                      ? (image.url.isNotEmpty
                          ? CircleAvatar(
                              radius: 40,
                              backgroundColor: RepathyStyle.backgroundColor,
                              backgroundImage: image,
                            )
                          : CircleAvatar(
                              radius: 40,
                              child: Text('$nameInitial$lastNameInitial',
                                  style: TextStyle(
                                    fontSize: RepathyStyle.giantTextSize,
                                    color: RepathyStyle.darkTextColor,
                                  )),
                            ))
                      : CircleAvatar(
                          radius: 40,
                          backgroundImage: FileImage(imageFileController),
                        ),
                ),
              ),
              Positioned(
                bottom: -16,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RepathyStyle.secondaryGradient,
                      ),
                    ),
                    Icon(
                      Icons.add,
                      size: 32,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
