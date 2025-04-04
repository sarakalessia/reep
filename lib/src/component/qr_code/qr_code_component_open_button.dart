import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/qr_code/qr_code_bottom_sheet.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QrCodeOpenButton extends ConsumerWidget {
  const QrCodeOpenButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userControllerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PrimaryButton(
          isRounded: true,
          text: AppLocalizations.of(context)!.showQrCode,
          onPressed: () async {
            showModalBottomSheet(
              context: context,
              builder: (context) => QrCodeBottomSheet(user: currentUser!),
            );
          },
        ),
      ],
    );
  }
}
