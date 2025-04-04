import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/component/input/input_field.dart';
import 'package:repathy/src/component/input/input_password_field.dart';
import 'package:repathy/src/component/page_structure/login_or_register_structure.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:repathy/src/util/key/keys.dart';
import 'package:repathy/src/theme/styles.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginOrRegisterStructure(
      primaryButtonTitle: AppLocalizations.of(context)!.loginButton,
      formKey: loginKey,
      pageTitle: AppLocalizations.of(context)!.login,
      showSecondaryButton: true,
      secondaryButtonPath: '/register-decision',
      secondaryButtonSupportText: AppLocalizations.of(context)!.arentYouRegistered,
      secondaryButtonClickableText: AppLocalizations.of(context)!.registration,
      childrenWidgets: [
        InputFormField(
          controller: loginController,
          name: '${AppLocalizations.of(context)!.email}*',
          validator: (value) => ref.read(formControllerProvider.notifier).validateEmail(value, context),
          shouldCapitalizeSentence: false,
          suffixIcon: const Icon(Icons.person, color: RepathyStyle.smallIconColor),
          left: 16,
          right: 16,
        ),
        InputPasswordField(
          controller: passwordController,
          validator: (value) => ref.read(formControllerProvider.notifier).validatePassword(value, context),
          left: 16 ,
          right: 16,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => ref.read(goRouterProvider).go('/forgot-password'),
                child: Text(
                AppLocalizations.of(context)!.forgotPassword,
                style: TextStyle(
                  color: RepathyStyle.defaultTextColor,
                  fontSize: RepathyStyle.smallTextSize,
                  decoration: TextDecoration.underline,
                ),
                ),
              ),
            ],
          ),
        )
      ],
      onPressed: () async {
        await ref.read(formControllerProvider.notifier).handleForm(
          actions: [
            () async => await ref.read(userControllerProvider.notifier).signInWithEmailAndPassword(loginController.text, passwordController.text),
          ],
          route: '/',
          globalKey: loginKey,
          context: context,
        );
      },
    );
  }
}
