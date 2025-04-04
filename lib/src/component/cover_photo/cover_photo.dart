import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/cover_photo/cover_photo_bottom_sheet.dart';
import 'package:repathy/src/controller/profile_image_controller/profile_image_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class CoverPhoto extends ConsumerWidget {
  const CoverPhoto({super.key, required this.cover});

  final NetworkImage cover;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final File? imageFileController = ref.watch(imageFileControllerProvider(isCover: true));
    final UserModel? currentUser = ref.watch(userControllerProvider);

    return GestureDetector(
      onTap: () async {
        showModalBottomSheet(
          context: context,
          builder: (context) => CoverPhotoBottomSheet(user: currentUser!),
        );
      },
      child: Container(
        height: 120,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: imageFileController != null
              ? DecorationImage(image: FileImage(imageFileController), fit: BoxFit.cover)
              : cover.url.isNotEmpty
                  ? DecorationImage(image: cover, fit: BoxFit.cover)
                  : null,
          color: RepathyStyle.backgroundColor,
          border: imageFileController == null && cover.url.isEmpty
              ? Border(
                  bottom: BorderSide(
                    color: RepathyStyle.lightPrimaryColor, // Adjust the color as needed
                    width: 1.0, // Adjust the width as needed
                  ),
                )
              : null,
        ),
        child: imageFileController == null && cover.url.isEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(0, 48, 48, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RepathyStyle.secondaryGradient,
                        ),
                      ),
                      Icon(
                        Icons.add,
                        size: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
