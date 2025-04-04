import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/component/page_structure/login_or_register_structure.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/util/key/keys.dart';
import 'package:repathy/src/theme/styles.dart';

class ForgotPasswordConfirmation extends ConsumerStatefulWidget {
  const ForgotPasswordConfirmation({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForgotPasswordConfirmationState();
}

class _ForgotPasswordConfirmationState extends ConsumerState<ForgotPasswordConfirmation> {

  @override
  Widget build(BuildContext context) {
    return LoginOrRegisterStructure(
      primaryButtonTitle: AppLocalizations.of(context)!.login,
      formKey: forgotPasswordKey,
      pageTitle: 'Password inviata',
      childrenWidgets: [
        const SizedBox(height: 16),
        Icon(Icons.check_rounded, color: Colors.green, size: 100),
        Text(
          'Password inviata',
          style: TextStyle(fontSize: RepathyStyle.largeTextSize, color: RepathyStyle.darkTextColor, fontWeight: RepathyStyle.semiBoldFontWeight),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Il link per reimpostare la password è stato inviato all\'indirizzo email inserito',
            style: TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ],
      onPressed: () => ref.read(goRouterProvider).go('/login'),
    );
  }
}