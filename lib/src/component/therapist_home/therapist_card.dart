import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/qr_code/qr_code_bottom_sheet.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class TherapistCard extends ConsumerWidget {
  const TherapistCard({
    super.key,
    required this.userModel,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
  });

  final UserModel userModel;
  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userControllerProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => QrCodeBottomSheet(user: user!),
          ).then((_) async {
            await ref.read(userControllerProvider.notifier).syncCachedUserWithDatabase();
          });
        },
        child: Container(
          height: 156,
          decoration: BoxDecoration(
            color: RepathyStyle.primaryColor,
            borderRadius: BorderRadius.circular(RepathyStyle.roundedRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ciao ${userModel.name}',
                        style: const TextStyle(
                          color: RepathyStyle.backgroundColor,
                          fontSize: RepathyStyle.largeTextSize,
                          fontWeight: RepathyStyle.standardFontWeight,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Fai scansionare il tuo',
                        style: const TextStyle(
                            color: RepathyStyle.backgroundColor,
                            fontSize: RepathyStyle.therapistCardDescriptionSize,
                            fontWeight: RepathyStyle.lightFontWeight,
                            height: 1),
                      ),
                      Text(
                        'QR code ai tuoi pazienti!',
                        style: const TextStyle(
                          color: RepathyStyle.backgroundColor,
                          fontSize: RepathyStyle.therapistCardDescriptionSize,
                          fontWeight: RepathyStyle.lightFontWeight,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset('assets/image/qr_code.png'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
