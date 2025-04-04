import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/current_text_controller/current_text_controller.dart';
import 'package:repathy/src/theme/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:repathy/src/util/helper/text_debouncer/text_debouncer.dart';

class CustomSearchBar extends ConsumerStatefulWidget {
  const CustomSearchBar({
    super.key,
    this.hintText,
    this.leftPadding = 12,
    this.topPadding = 16,
    this.rightPadding = 12,
    this.bottomPadding = 24,
  });

  final String? hintText;
  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends ConsumerState<CustomSearchBar> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(textDebouncerProvider);
    ref.watch(currentTextControllerProvider);

    return Container(
      margin: EdgeInsets.fromLTRB(widget.leftPadding, widget.topPadding, widget.rightPadding, widget.bottomPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: RepathyStyle.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 20,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: TextField(
        controller: textEditingController,
        decoration: InputDecoration(
          labelText: widget.hintText ?? AppLocalizations.of(context)!.search,
          labelStyle: const TextStyle(
            color: RepathyStyle.smallIconColor,
            fontSize: RepathyStyle.smallTextSize,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: RepathyStyle.smallIconSize,
          ),
          prefixIconColor: RepathyStyle.smallIconColor,
          suffixIcon: IconButton(
            onPressed: () {
              ref.read(currentTextControllerProvider.notifier).clearText();
              textEditingController.clear();
              
            },
            icon: Icon(Icons.close, size: RepathyStyle.smallIconSize),
          ),
          suffixIconColor: RepathyStyle.smallIconColor,
          border: InputBorder.none,
        ),
        onChanged: (value) {
          ref.read(textDebouncerProvider.notifier).run(() {
            ref.read(currentTextControllerProvider.notifier).updateText(value);
          });
        },
      ),
    );
  }
}
