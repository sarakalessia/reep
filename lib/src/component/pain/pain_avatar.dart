import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/pain_controller/pain_controller.dart';
import 'package:repathy/src/model/component_models/pain_component_model/pain_component_model.dart';
import 'package:repathy/src/theme/styles.dart';

class PainAvatar extends ConsumerStatefulWidget {
  const PainAvatar({
    super.key,
    required this.painComponent,
    required this.index,
  });

  final PainComponentModel painComponent;
  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PainAvatarState();
}

class _PainAvatarState extends ConsumerState<PainAvatar> {
  @override
  Widget build(BuildContext context) {
    final List<PainComponentModel> painComponentList = ref.watch(painControllerProvider);
    final PainComponentModel currentPainComponent = painComponentList[widget.index];

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: GestureDetector(
        onTap: () {
          ref.read(painControllerProvider.notifier).togglePainSelection(widget.index);
          debugPrint('PainAvatar index: ${widget.index} value is ${currentPainComponent.isSelected}');
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: currentPainComponent.isSelected ? RepathyStyle.primaryColor : RepathyStyle.lightBorderColor,
              width: 5.0,
            ),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.transparent,
            child: Image.asset(
              currentPainComponent.isSelected ? widget.painComponent.selectedPath! : widget.painComponent.path!,
              width: 30,
              height: 30,
            ),
          ),
        ),
      ),
    );
  }
}
