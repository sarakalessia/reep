import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/generic_add_button.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/util/enum/media_format_enum.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class PatientDetailsCard extends ConsumerWidget {
  const PatientDetailsCard({
    super.key,
    required this.title,
    required this.index,
    required this.subPage,
    required this.function,
    required this.mediaFormatEnum,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
    this.widthScale = 1,
    this.height = 145,
    this.hasTextButton = true,
  });

  final String title;
  final int index;
  final PageEnum subPage;
  final Function function;
  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;
  final double height;
  final double widthScale;
  final bool hasTextButton;
  final MediaFormatEnum mediaFormatEnum;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: GestureDetector(
        onTap: () {
          ref.read(mediaFormatFilterProvider.notifier).updateMediaFormat(mediaFormatEnum);
          ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: index, subPage: subPage);
        },
        child: Container(
          height: height,
          width: MediaQuery.sizeOf(context).width * widthScale,
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GenericAddButton(function: function),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: RepathyStyle.defaultTextColor,
                        fontSize: RepathyStyle.standardTextSize,
                        fontWeight: RepathyStyle.semiBoldFontWeight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
