import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/controller/invitation_controller/invitation_controller.dart';
import 'package:repathy/src/controller/therapist_controller/therapist_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScanQrCodePage extends ConsumerStatefulWidget {
  const ScanQrCodePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScanQrCodePageState();
}

class _ScanQrCodePageState extends ConsumerState<ScanQrCodePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => ref.read(goRouterProvider).go('/therapist-invitation'),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text(AppLocalizations.of(context)!.scanQrCode),
      ),
      body: 
      Container()
      // MobileScanner(
      //   controller: MobileScannerController(
      //     detectionSpeed: DetectionSpeed.noDuplicates,
      //   ),
      //   onDetect: (BarcodeCapture barcodes) async {
      //     final String qrCodeId = barcodes.barcodes.first.rawValue ?? '';
      //     if (qrCodeId.isEmpty) ref.read(goRouterProvider).go('/therapist-invitation', extra: {'scan-error': 'QR code is empty'});
      //     final result = await ref.read(invitationControllerProvider.notifier).automaticAcceptanceViaQrCode(qrCodeId);
      //     if (!result) return;
      //     final therapistResult = await ref.read(getTherapistByQrCodeIdProvider(qrCodeId).future);
      //     final therapistModel = therapistResult.data;
      //     if (therapistModel != null) {
      //       debugPrint('View: ScanQrCodePage: $therapistModel');
      //       await ref.read(userControllerProvider.notifier).syncCachedUserWithDatabase();
      //       final String name = therapistModel.name ?? '';
      //       ref.read(goRouterProvider).go('/qr-code-success', extra: {'name': name});
      //     } else {
      //       ref.read(goRouterProvider).go('/therapist-invitation', extra: {'scan-error': 'QR code error, try sending an invite'});
      //     }
      //   },
      // ),
    );
  }
}
