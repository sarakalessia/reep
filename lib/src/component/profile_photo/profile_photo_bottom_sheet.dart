import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/bottom_sheet_controller/bottom_sheet_controller.dart';
import 'package:repathy/src/controller/profile_image_controller/profile_image_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class ProfilePhotoBottomSheet extends ConsumerStatefulWidget {
  const ProfilePhotoBottomSheet({super.key, required this.user});

  final UserModel user;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePhotoBottomSheetState();
}

class _ProfilePhotoBottomSheetState extends ConsumerState<ProfilePhotoBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final standardPhotoList = ref.watch(getStandardProfilePhotosFromFirestoreProvider);
    final isLoading = ref.watch(bottomSheetcontrollerProvider);

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
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: RepathyStyle.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          !isLoading
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 32, 8, 16),
                      child: Text(
                        'Scegli la tua foto profilo',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: RepathyStyle.standardTextSize,
                          fontWeight: RepathyStyle.standardFontWeight,
                          color: RepathyStyle.defaultTextColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: RepathyStyle.lightBorderColor,
                        borderRadius: BorderRadius.circular(RepathyStyle.standardRadius),
                      ),
                      child: ListTile(
                        title: Padding(padding: const EdgeInsets.only(left: 8), child: Text('Scegli una foto dalla tua galleria')),
                        onTap: () async {
                          ref.read(bottomSheetcontrollerProvider.notifier).setToTrue();
                          await ref.read(imageFileControllerProvider(isCover: false).notifier).getImageFromGalleryAndSave();
                          if (context.mounted) Navigator.pop(context);
                          ref.read(bottomSheetcontrollerProvider.notifier).setToFalse();
                        },
                        trailing: Stack(
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
                    ),
                    const SizedBox(height: 16),
                    standardPhotoList.when(
                      data: (ResultModel<List<String>> data) {
                        final result = data.data;
                        if (result == null) return const SizedBox.shrink();
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Scegli un avatar',
                              style: const TextStyle(
                                fontSize: RepathyStyle.standardTextSize,
                                fontWeight: RepathyStyle.standardFontWeight,
                                color: RepathyStyle.defaultTextColor,
                              ),
                            ),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: result.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        ref.read(bottomSheetcontrollerProvider.notifier).setToTrue();
                                        await ref.read(userControllerProvider.notifier).saveRepathyStandardProfileImage(result[index]);
                                        if (context.mounted) Navigator.pop(context);
                                        ref.read(bottomSheetcontrollerProvider.notifier).setToFalse();
                                      },
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage: NetworkImage(result[index]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                      error: (error, stackTrace) => SizedBox.shrink(),
                      loading: () => Transform.scale(scale: 0.5, child: const CircularProgressIndicator()),
                    ),
                    SizedBox(height: 32),
                    if (widget.user.profileImage != null) ...[
                      TextButton(
                        onPressed: () async {
                          if (widget.user.profileImage != null) {
                            ref.read(bottomSheetcontrollerProvider.notifier).setToTrue();
                            final result = await ref.read(userControllerProvider.notifier).deleteProfileImage();
                            final resultData = result.data;
                            if (resultData != null && resultData) ref.read(userControllerProvider.notifier).syncCachedUserWithDatabase();
                            if (context.mounted) Navigator.pop(context);
                            ref.read(bottomSheetcontrollerProvider.notifier).setToFalse();
                          }
                        },
                        child: Text(
                          'Elimina foto',
                          style: TextStyle(color: RepathyStyle.errorColor),
                        ),
                      ),
                    ]
                  ],
                )
              : Padding(
                padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * 0.2),
                child: CircularProgressIndicator(),
              ),
        ],
      ),
    );
  }
}
