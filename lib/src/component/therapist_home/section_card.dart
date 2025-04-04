import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class SectionCard extends ConsumerWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.index,
    required this.subPage,
    required this.onAddCallback,
    required this.backgroundImage,
    this.conditionCallBack,
    this.backgroundImageScale = 45,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
    this.dataSource,
    this.widthScale = 0.42,
    this.imageLeftPadding = 16,
    this.imageTopPadding = 28,
    this.imageRightPadding = 16,
    this.imageBottomPadding = 4,
  });

  final String title;
  final String description;
  final int index;
  final PageEnum subPage;
  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;
  final Object? dataSource;
  final Function onAddCallback;
  final bool Function()? conditionCallBack;
  final double widthScale;
  final String backgroundImage;
  final double backgroundImageScale;
  final double imageLeftPadding;
  final double imageTopPadding;
  final double imageRightPadding;
  final double imageBottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLargeBox = widthScale == 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: GestureDetector(
        onTap: () {
          bool result = conditionCallBack?.call() ?? true;
          if (result) ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: index, subPage: subPage);
        },
        child: Container(
          height: 155,
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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(imageLeftPadding, imageTopPadding, imageRightPadding, imageBottomPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      backgroundImage,
                      color: RepathyStyle.primaryColor,
                      scale: backgroundImageScale,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            height: 1,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
