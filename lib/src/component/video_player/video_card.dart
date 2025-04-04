import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class VideoCard extends ConsumerWidget {
  const VideoCard({
    super.key,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
    this.dataSource,
  });

  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;
  final MediaModel? dataSource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: GestureDetector(
        onTap: () async {
          final String? path = dataSource?.mediaPath;
          final UserModel? currentUser = ref.read(userControllerProvider);
          if (path == null) return;
          ref.read(goRouterProvider).go(
            '/video-player',
            extra: {
              'media': dataSource,
              'currentUser': currentUser,
            },
          );
        },
        child: Container(
          height: 155,
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
            color: RepathyStyle.backgroundColor,
            borderRadius: BorderRadius.circular(RepathyStyle.roundedRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[300]!,
                offset: Offset(4, 2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 40, 0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/pain/hip_pain.png',
                        scale: 0.7,
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  size: 60,
                  color: RepathyStyle.lightPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
