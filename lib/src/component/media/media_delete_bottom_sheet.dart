import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/util/enum/media_format_enum.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class DeleteMediaBottomSheet extends ConsumerWidget {
  const DeleteMediaBottomSheet({super.key, required this.currentMedia});

  final MediaModel currentMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaFormat = currentMedia.mediaFormat;
    final text = mediaFormat != MediaFormatEnum.pdf ? 'video' : 'PDF';

    return Container(
      height: 300,
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
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: RepathyStyle.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 32, 8, 16),
              child: Text(
                'Sei sicuro che vuoi eliminare questo $text?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: RepathyStyle.standardTextSize,
                  fontWeight: RepathyStyle.standardFontWeight,
                  color: RepathyStyle.defaultTextColor,
                ),
              ),
            ),
            PrimaryButton(
              isRemove: true,
              text: 'Conferma',
              onPressed: () async {
                await ref.read(mediaControllerProvider.notifier).deleteMedia(media: currentMedia, therapistId: currentMedia.therapistId!);
                if (context.mounted) Navigator.of(context).pop();
                ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 2, subPage: PageEnum.none);
              },
            ),
          ],
        ),
      ),
    );
  }
}
