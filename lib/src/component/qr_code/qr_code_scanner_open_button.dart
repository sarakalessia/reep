import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QrCodeScannerButton extends ConsumerWidget {
  const QrCodeScannerButton({
    super.key,
    this.leftPadding = 0,
    this.topPadding = 0,
    this.rightPadding = 0,
    this.bottomPadding = 0,
  });

  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PrimaryButton(
            isRounded: false,
            text: AppLocalizations.of(context)!.scanQrCode,
            onPressed: () => ref.read(goRouterProvider).go('/scan-qr-code'),
          ),
        ],
      ),
    );
  }
}
