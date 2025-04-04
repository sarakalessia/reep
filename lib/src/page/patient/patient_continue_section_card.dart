import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class PatientContinueSectionCard extends ConsumerWidget {
  const PatientContinueSectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.index,
    required this.subPage,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
    this.widthScale = 0.42,
    this.height = 90,
    this.hasTextButton = true,
  });

  final String title;
  final String description;
  final int index;
  final PageEnum subPage;
  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;
  final double height;
  final double widthScale;
  final bool hasTextButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLargeBox = widthScale == 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: GestureDetector(
        onTap: () => ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: index, subPage: subPage),
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
            gradient: LinearGradient(
              colors: [
                isLargeBox ? RepathyStyle.lightPrimaryColor : RepathyStyle.lightPrimaryColor.withValues(alpha: 0.4),
                RepathyStyle.backgroundColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [isLargeBox ? 0.05 : 0.01, isLargeBox ? 0.6 : 0.6],
              transform: GradientRotation(isLargeBox ? 0.9 : 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: RepathyStyle.defaultTextColor,
                        fontSize: RepathyStyle.standardTextSize,
                        fontWeight: RepathyStyle.semiBoldFontWeight,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        color: RepathyStyle.defaultTextColor,
                        fontSize: RepathyStyle.smallTextSize,
                        fontWeight: RepathyStyle.lightFontWeight,
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
