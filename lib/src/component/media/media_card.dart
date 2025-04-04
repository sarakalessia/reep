import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/controller/pain_controller/pain_controller.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/util/enum/media_format_enum.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/util/enum/pain_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class MediaCard extends ConsumerStatefulWidget {
  const MediaCard({super.key, required this.mediaModel});

  final MediaModel mediaModel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MediaCardState();
}

class _MediaCardState extends ConsumerState<MediaCard> {
  String? mediaPath;
  String? mediaTitle;
  String? mediaNetworkPath;
  MediaFormatEnum? mediaFormat;

  @override
  void initState() {
    loadDependencies();
    super.initState();
  }

  loadDependencies() {
    final List<PainEnum> painEnumList = widget.mediaModel.painEnum;
    final PainEnum painEnum = painEnumList.first;
    mediaPath = ref.read(painControllerProvider.notifier).extractPainPathFromPainEnum(painEnum);
    mediaNetworkPath = widget.mediaModel.mediaPath;
    mediaTitle = widget.mediaModel.title;
    mediaFormat = widget.mediaModel.mediaFormat;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(mediaControllerProvider);

    return GestureDetector(
      onTap: () {
        if (mediaPath != null) {
          ref.read(mediaControllerProvider.notifier).updateState(widget.mediaModel);
          ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 2, subPage: PageEnum.videoDetail);
        }
      },
      child: Container(
        height: 125,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: RepathyStyle.backgroundColor,
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    mediaFormat == MediaFormatEnum.pdf ? Icons.picture_as_pdf : Icons.videocam,
                    size: RepathyStyle.smallIconSize,
                    color: RepathyStyle.primaryColor,
                  ),
                ],
              ),
            Image.asset(mediaPath ?? 'assets/logo/ios_icon_transparent.png', height: 40),
            if (mediaTitle != null) ...[
              Text(
                textAlign: TextAlign.center,
                mediaTitle!,
                style: TextStyle(
                  fontSize: RepathyStyle.smallTextSize,
                  color: RepathyStyle.smallIconColor,
                  fontWeight: RepathyStyle.lightFontWeight,
                ),
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
