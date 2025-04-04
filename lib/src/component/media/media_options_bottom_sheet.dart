import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/media/media_option_tile.dart';
import 'package:repathy/src/controller/bottom_nav_bar_controller/bottom_nav_bar_controller.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/file_controller/file_controller.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class MediaOptionsBottomSheet extends ConsumerWidget {
  const MediaOptionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 473,
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(RepathyStyle.roundedRadius),
          topRight: Radius.circular(RepathyStyle.roundedRadius),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RepathyStyle.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 32),
            MediaOptionTile(
              function: () async {
                File? file = await ref.read(mediaControllerProvider.notifier).captureMediaWithCamera(isVideo: true);
                if (file != null) {
                ref.read(currentFileControllerProvider.notifier).setFile(file);
                if (context.mounted) Navigator.of(context).pop();
                if (context.mounted) ref.read(bottomNavBarVisibilityProvider(context).notifier).toggleVisibility();
                  ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 2, subPage: PageEnum.newVideo);
                }
              },
              text: 'Video',
              icon: Icons.camera_alt_outlined,
            ),
            MediaOptionTile(
              function: () {
                if (context.mounted) Navigator.of(context).pop();
                if (context.mounted) ref.read(bottomNavBarVisibilityProvider(context).notifier).toggleVisibility();
                ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 2, subPage: PageEnum.newPdf);
              },
              text: 'PDF',
              icon: Icons.picture_as_pdf_outlined,
            ),
            MediaOptionTile( 
              function: () async {
                File? file = await ref.read(mediaControllerProvider.notifier).pickMediaFromGallery(isVideo: true);
                if (file != null) {
                  ref.read(currentFileControllerProvider.notifier).setFile(file);
                  if (context.mounted) Navigator.of(context).pop();
                  if (context.mounted) ref.read(bottomNavBarVisibilityProvider(context).notifier).toggleVisibility();
                  ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 2, subPage: PageEnum.newVideo);
                }
              },
              text: 'Importa video',
              icon: Icons.video_camera_back_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
