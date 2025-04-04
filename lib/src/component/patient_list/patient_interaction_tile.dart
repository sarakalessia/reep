import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_interaction_model/media_interaction_model.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/theme/styles.dart';

class PatientInteractionTile extends ConsumerWidget {
  const PatientInteractionTile({super.key, required this.patientModel, required this.mediaModel, required this.mediaInteraction});

  final UserModel patientModel;
  final MediaModel mediaModel;
  final MediaInteractionModel mediaInteraction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: ListTile(
        tileColor: RepathyStyle.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RepathyStyle.standardRadius),
          side: BorderSide(color: RepathyStyle.borderColor, width: 1.5),
        ),
        title: Padding(padding: const EdgeInsets.only(left: 8), child: Text('${patientModel.name} ${patientModel.lastName} ha riprodotto')),
        subtitle: Padding(padding: const EdgeInsets.only(left: 8), child: Text('il video ${mediaModel.title}')),
        onTap: () {},
        trailing: Text(formatter.format(mediaInteraction.openedAt!)),
      ),
    );
  }
}
