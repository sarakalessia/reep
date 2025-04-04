import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/util/enum/element_size_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class GenericAddButton extends ConsumerWidget {
  const GenericAddButton({
    super.key,
    required this.function,
    this.size = ElementSize.standard,
    this.leftPadding = 0,
    this.topPadding = 8,
    this.rightPadding = 0,
    this.bottomPadding = 8,
  });

  final Function function;
  final ElementSize size;
  final double leftPadding;
  final double topPadding;
  final double rightPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
      height: size == ElementSize.standard ? 48 : 40,
      width: size == ElementSize.standard ? 48 : 40,
      decoration: BoxDecoration(
        color: RepathyStyle.primaryColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: IconButton(
        onPressed: () => function(),
        icon: Icon(
          Icons.add,
          size: size == ElementSize.standard ? 34 : 24,
          color: RepathyStyle.backgroundColor,
        ),
      ),
    );
  }
}
