import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/util/enum/element_size_enum.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QrCodeSuccessPage extends ConsumerStatefulWidget {
  const QrCodeSuccessPage({super.key, required this.name});

  final String name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QrCodeSuccessPageState();
}

class _QrCodeSuccessPageState extends ConsumerState<QrCodeSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RepathyStyle.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 8,
            child: Column(
              children: [
                const SizedBox(height: 72),
                Image.asset('assets/logo/ios_icon_transparent.png', height: 56, width: 60),
                const SizedBox(height: 8),
                PageTitleText(title: AppLocalizations.of(context)!.requestSentTitle),
                const SizedBox(height: 64),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 55.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: RepathyStyle.standardTextSize,
                        fontWeight: RepathyStyle.lightFontWeight,
                        color: RepathyStyle.defaultTextColor,
                      ),
                      children: [
                        TextSpan(text: AppLocalizations.of(context)!.requestSentDescriptionPartOne),
                        TextSpan(
                          text: 'terapista ${widget.name} ',
                          style: const TextStyle(
                            fontSize: RepathyStyle.standardTextSize,
                            fontWeight: RepathyStyle.standardFontWeight,
                            color: RepathyStyle.defaultTextColor,
                          ),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.requestSentDescriptionPartFour,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                PrimaryButton(
                  text: AppLocalizations.of(context)!.goToApp,
                  onPressed: () => ref.read(goRouterProvider).go('/'),
                  size: ElementSize.standard,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
