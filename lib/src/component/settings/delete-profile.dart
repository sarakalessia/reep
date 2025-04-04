import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../util/helper/url_launcher/url_launcher.dart';

class DeleteProfileSheet extends ConsumerStatefulWidget {
  const DeleteProfileSheet({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DeleteProfileSheetState();
}

class _DeleteProfileSheetState extends ConsumerState<DeleteProfileSheet> {
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
              "Per eliminare l'account recati sul sito di repathy.com e contattattaci direttamente da lì!",
            ),
          ),
          GestureDetector(
            child: Text("Elimina l'account su repathy.com"),
            onTap: () => ref.read(launchBrowserUrlProvider("https://repathy.com")),
          )
        ],
      ),
    );
  }
}
