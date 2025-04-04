import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/pain_controller/pain_controller.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/util/enum/pain_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class PainCard extends ConsumerWidget {
  const PainCard({
    super.key,
    required this.title,
    required this.painPath,
    required this.painEnum,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
  });

  final String title;
  final String painPath;
  final PainEnum painEnum;
  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(currentPainControllerProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: GestureDetector(
        onTap: () {
          ref.read(currentPainControllerProvider.notifier).updateCurrentPain(painEnum);
          ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 2, subPage: PageEnum.patientLibrary);
        },
        child: Container(
          decoration: BoxDecoration(
            color: RepathyStyle.backgroundColor,
            borderRadius: BorderRadius.circular(RepathyStyle.roundedRadius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                offset: Offset(0, 0),
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            painPath,
                            width: 50,
                            height: 50,
                          ),
                          SizedBox(height: 8),
                          Text(
                            title,
                            style: const TextStyle(
                              color: RepathyStyle.defaultTextColor,
                              fontSize: RepathyStyle.standardTextSize,
                              fontWeight: RepathyStyle.standardFontWeight,
                              height: 1
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
