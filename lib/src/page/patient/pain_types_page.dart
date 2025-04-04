import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/pain/pain_card.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/util/constant/pain_list_const.dart';

class PainTypesPage extends ConsumerStatefulWidget {
  const PainTypesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PainTypesPageState();
}

class _PainTypesPageState extends ConsumerState<PainTypesPage> {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                    child: Align(alignment: Alignment.centerLeft, child: PageTitleText(title: 'Esercizi')),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Align(alignment: Alignment.centerLeft, child: PageDescriptionText(title: 'Scegli gli esercizi in base al tuo sintomo')),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.2, // Adjust the aspect ratio as needed
              ),
              itemCount: painPathList.length,
              itemBuilder: (context, index) {
                final entry = painPathList.entries.elementAt(index);
                return PainCard(
                  title: painTitles[entry.key] ?? 'Unknown Pain',
                  painPath: entry.value,
                  leftPadding: 0,
                  topPadding: 0,
                  rightPadding: 0,
                  bottomPadding: 0,
                  painEnum: entry.key,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
