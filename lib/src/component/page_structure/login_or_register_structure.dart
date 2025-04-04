import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/button/text_button.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/theme/styles.dart';

class LoginOrRegisterStructure extends ConsumerWidget {
  const LoginOrRegisterStructure({
    super.key,
    required this.primaryButtonTitle,
    required this.onPressed,
    required this.childrenWidgets,
    required this.formKey,
    required this.pageTitle,
    this.showSecondaryButton = false,
    this.secondaryButtonPath,
    this.secondaryButtonSupportText,
    this.secondaryButtonClickableText,
  });

  final String pageTitle;
  final String primaryButtonTitle;
  final FutureOr<void> Function() onPressed;
  final List<Widget> childrenWidgets;
  final GlobalKey<FormState> formKey;
  final bool showSecondaryButton;
  final String? secondaryButtonPath;
  final String? secondaryButtonSupportText;
  final String? secondaryButtonClickableText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: RepathyStyle.backgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: RepathyStyle.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Center(
          child: Column(
            children: [
              PageTitleText(title: pageTitle),
              SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Center(
                      child: Column(
                        children: childrenWidgets,
                      ),
                    ),
                  ),
                ),
              ),
              PrimaryButton(text: primaryButtonTitle, onPressed: onPressed),
              if (showSecondaryButton == true &&
                  secondaryButtonPath != null &&
                  secondaryButtonSupportText != null &&
                  secondaryButtonClickableText != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PrimaryTextButton(
                      path: secondaryButtonPath!,
                      supportText: '${secondaryButtonSupportText!} ',
                      clickableText: secondaryButtonClickableText!,
                    ),
                  ],
                ),
              ],
              SizedBox(height: 20), 
            ],
          ),
        ),
      ),
    );
  }
}
