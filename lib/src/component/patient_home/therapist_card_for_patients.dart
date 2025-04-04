import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/component/button/generic_add_button.dart';
import 'package:repathy/src/component/profile_photo/profile_photo_read_only.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/therapist_controller/therapist_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class TherapistCardForPatients extends ConsumerWidget {
  const TherapistCardForPatients({
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
    final therapist = ref.watch(getUserModelByIdProvider(userModel.therapistId.firstOrNull));

    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: RepathyStyle.primaryColor,
          borderRadius: BorderRadius.circular(RepathyStyle.roundedRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              therapist.when(
                data: (data) {
                  final therapist = data.data;
                  if (therapist == null) return _noTherapistWidget(ref);
                  return GestureDetector(
                    onTap: () {
                      ref.read(currentTherapistProvider.notifier).selectUser(therapist);
                      ref
                          .read(subPageControllerProvider.notifier)
                          .navigateToSubPage(index: 1, subPage: PageEnum.therapistPublicProfile);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Il tuo terapista',
                                style: const TextStyle(
                                  color: RepathyStyle.backgroundColor,
                                  fontSize: RepathyStyle.largeTextSize,
                                  fontWeight: RepathyStyle.standardFontWeight,
                                ),
                              ),
                              Text(
                                '${therapist.name}',
                                style: const TextStyle(
                                  color: RepathyStyle.backgroundColor,
                                  fontSize: RepathyStyle.largeTextSize,
                                  fontWeight: RepathyStyle.standardFontWeight,
                                  height: 0,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        ProfilePhotoReadOnly(
                          image: NetworkImage(therapist.profileImage ?? ''),
                          hasGradient: false,
                          otherUser: therapist,
                        ),
                      ],
                    ),
                  );
                },
                error: (error, stackTrace) => _noTherapistWidget(ref),
                loading: () => CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noTherapistWidget(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Nessun terapista',
          style: const TextStyle(
            color: RepathyStyle.backgroundColor,
            fontSize: RepathyStyle.largeTextSize,
            fontWeight: RepathyStyle.standardFontWeight,
          ),
        ),
        GenericAddButton(function: () => ref.read(goRouterProvider).go('/therapist-invitation')),
      ],
    );
  }
}
