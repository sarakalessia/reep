import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:repathy/src/model/data_models/announcement_model/announcement_model.dart';
import 'package:repathy/src/theme/styles.dart';

class AnnouncementsCard extends ConsumerWidget {
  const AnnouncementsCard({super.key, required this.announcementModel});

  final AnnouncementModel announcementModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final formattedDate = DateFormat('dd/MM/yyyy').format(announcementModel.sentAt!);

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: RepathyStyle.standardTextSize,
              fontWeight: RepathyStyle.lightFontWeight,
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: MediaQuery.sizeOf(context).width * 0.9,
            height: RepathyStyle.announcementCardHeight,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: RepathyStyle.lightBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Text(
                announcementModel.content ?? '',
                style: TextStyle(
                  fontSize: RepathyStyle.smallTextSize,
                  fontWeight: RepathyStyle.lightFontWeight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
