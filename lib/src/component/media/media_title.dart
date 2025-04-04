import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/controller/read_or_edit_controller.dart/read_or_edit_controller.dart';
import 'package:repathy/src/theme/styles.dart';

class MediaTitle extends ConsumerStatefulWidget {
  const MediaTitle({super.key, required this.textEditingController, required this.isVideo});

  final TextEditingController textEditingController;
  final bool isVideo;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MediaTitleState();
}

class _MediaTitleState extends ConsumerState<MediaTitle> {
  @override
  Widget build(BuildContext context) {
    final bool isRead = ref.watch(readOrEditControllerProvider);
    String title = widget.isVideo ? 'Nuovo video' : 'Nuovo PDF';
    String hintText = widget.isVideo ? 'Titolo del video' : 'Titolo del PDF';

    return Row(
      children: [
        isRead
            ? Expanded(
                child: PageTitleText(
                title: widget.textEditingController.text.isEmpty ? title : widget.textEditingController.text,
              ))
            : SizedBox(
                width: 180,
                child: TextField(
                  maxLength: 30,
                  controller: widget.textEditingController,
                  style: const TextStyle(
                    fontSize: RepathyStyle.largeTextSize,
                    fontWeight: RepathyStyle.standardFontWeight,
                    color: RepathyStyle.darkTextColor,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      fontSize: RepathyStyle.largeTextSize,
                      fontWeight: RepathyStyle.standardFontWeight,
                      color: RepathyStyle.inputFieldHintTextColor,
                    ),
                  ),
                ),
              ),
        IconButton(
            onPressed: () => ref.read(readOrEditControllerProvider.notifier).toggleState(),
            icon: Icon(
              isRead ? Icons.edit : Icons.check,
              color: RepathyStyle.primaryColor,
            )),
      ],
    );
  }
}
