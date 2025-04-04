import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QrCodeBottomSheet extends ConsumerStatefulWidget {
  const QrCodeBottomSheet({super.key, required this.user});

  final UserModel user;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QrCodeBottomSheetState();
}

class _QrCodeBottomSheetState extends ConsumerState<QrCodeBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 473,
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(RepathyStyle.roundedRadius),
          topRight: Radius.circular(RepathyStyle.roundedRadius),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: RepathyStyle.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 8, 16),
            child: Text(
              AppLocalizations.of(context)!.scanThisQrCode,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: RepathyStyle.standardTextSize,
                fontWeight: RepathyStyle.standardFontWeight,
                color: RepathyStyle.defaultTextColor,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.6,
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
            child: PrettyQrView.data(data: widget.user.qrCodeId!),
          ),
        ],
      ),
    );
  }
}
