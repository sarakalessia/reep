import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/input/input_field.dart';
import 'package:repathy/src/component/page_structure/login_or_register_structure.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/util/key/keys.dart';
import 'package:repathy/src/theme/styles.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginOrRegisterStructure(
      primaryButtonTitle: AppLocalizations.of(context)!.sendRequestButton,
      formKey: forgotPasswordKey,
      pageTitle: 'Ricupero password',
      showSecondaryButton: true,
      secondaryButtonPath: '/login',
      secondaryButtonSupportText: 'Hai trovato la password?',
      secondaryButtonClickableText: 'Accedi',
      childrenWidgets: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Inserisci l\'indirizzo email a cui desideri ricevere le informazioni per reimpostare la password',
            style: TextStyle(fontSize: 16, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        InputFormField(
          controller: emailController,
          name: AppLocalizations.of(context)!.email,
          validator: (value) => ref.read(formControllerProvider.notifier).validateEmail(value, context),
          shouldCapitalizeSentence: false,
          suffixIcon: const Icon(Icons.person, color: RepathyStyle.smallIconColor),
          left: 16,
          right: 16,
        ),
      ],
      onPressed: () async {
        await ref.read(formControllerProvider.notifier).handleForm(
          route: '/forgot-password-confirmation',
          globalKey: forgotPasswordKey,
          context: context,
          actions: [
            () async => await ref.read(userControllerProvider.notifier).resetPassword(emailController.text),
          ],
        );
      },
    );
  }
}
