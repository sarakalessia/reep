import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/pain/pain_avatar.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/controller/pain_controller/pain_controller.dart';
import 'package:repathy/src/model/component_models/pain_component_model/pain_component_model.dart';
import 'package:repathy/src/theme/styles.dart';

class PainAvatarCarrousel extends ConsumerStatefulWidget {
  const PainAvatarCarrousel({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PainAvatarCarrouselState();
}

class _PainAvatarCarrouselState extends ConsumerState<PainAvatarCarrousel> {
  @override
  Widget build(BuildContext context) {
    final List<PainComponentModel> painComponentList = ref.watch(painControllerProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.94,
        child: Card(
          color: RepathyStyle.lightBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          shadowColor: RepathyStyle.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 12, 0, 10),
                  child: Align(alignment: Alignment.centerLeft, child: PageDescriptionText(title: 'Sintomo')),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  height: 60,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      PainComponentModel painComponent = painComponentList[index];
                      return PainAvatar(painComponent: painComponent, index: index);
                    },
                    itemCount: painComponentList.length,
                    scrollDirection: Axis.horizontal,
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
