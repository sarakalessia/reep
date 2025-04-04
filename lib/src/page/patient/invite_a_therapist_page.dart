import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/component/therapist_invitation/therapist_invitation_header.dart';
import 'package:repathy/src/component/therapist_invitation/therapist_invitation_list.dart';
import 'package:repathy/src/component/therapist_invitation/therapist_invitation_send_button.dart';
import 'package:repathy/src/component/search_bar/search_bar.dart';
import 'package:repathy/src/component/qr_code/qr_code_scanner_open_button.dart';
import 'package:repathy/src/controller/therapist_controller/therapist_controller.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class TherapistInvitationPage extends ConsumerStatefulWidget {
  const TherapistInvitationPage({super.key, required this.scanError});

  final String? scanError;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TherapistInvitationPageState();
}

class _TherapistInvitationPageState extends ConsumerState<TherapistInvitationPage> {
  @override
  Widget build(BuildContext context) {
    final asyncFilteredTherapists = ref.watch(asyncFilteredTherapistsProvider(removeMyself: false));

    return Scaffold(
      backgroundColor: RepathyStyle.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          TherapistInvitationHeader(),
          CustomSearchBar(bottomPadding: 16, topPadding: 0),
          QrCodeScannerButton(bottomPadding: 8),
          ClipRRect(
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              height: 280, // MediaQuery.sizeOf(context).height * 0.32,
              child: asyncFilteredTherapists.when(
                data: (ResultModel<List<UserModel>> data) {
                  final List<UserModel> therapistsList = data.data ?? [];
                  return TherapistInvitationList(userList: therapistsList);
                },
                loading: () => Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Text('Error: $error'),
              ),
            ),
          ),
          TherapistInvitationSendButton(),
          TextButton(onPressed: () => ref.read(goRouterProvider).go('/'), child: Text('Salta')),
        ],
      ),
    );
  }
}
