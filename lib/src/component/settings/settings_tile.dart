import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/theme/styles.dart';

class SettingsTile extends ConsumerStatefulWidget {
  const SettingsTile({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final Function onTap;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsTileState();
}

class _SettingsTileState extends ConsumerState<SettingsTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RepathyStyle.lightRadius),
          side: BorderSide(color: RepathyStyle.borderColor, width: 1.0),
        ),
        tileColor: RepathyStyle.backgroundColor,
        trailing: _chooseWidget(),
        onTap: () => widget.onTap(),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 0, 16),
          child: Text(
            widget.title,
            style: TextStyle(
              fontWeight: RepathyStyle.standardFontWeight,
              color: widget.title == 'Elimina account' ? Colors.red : RepathyStyle.darkTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget? _chooseWidget() {
    if (widget.title == 'Elimina account' || widget.title == 'Logout') return null;
    return const Icon(
      Icons.arrow_forward_ios_rounded,
      color: RepathyStyle.darkTextColor,
      size: RepathyStyle.miniIconSize,
    );
  }
}
