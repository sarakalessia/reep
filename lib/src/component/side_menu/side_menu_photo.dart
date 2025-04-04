import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/profile_image_controller/profile_image_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class SideMenuProfilePhoto extends ConsumerWidget {
  const SideMenuProfilePhoto({
    super.key,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
  });

  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NetworkImage image = ref.watch(imageFromCurrentUserProvider(isCover: false));
    final UserModel? currentUser = ref.watch(userControllerProvider);
    final String nameInitial = currentUser?.name?.substring(0, 1).toUpperCase() ?? '';
    final String lastNameInitial = currentUser?.lastName?.substring(0, 1).toUpperCase() ?? '';

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(
              gradient: RepathyStyle.secondaryGradient,
              shape: BoxShape.circle,
            ),
            child: image.url.isNotEmpty
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
                  ),
          ),
        ],
      ),
    );
  }
}
