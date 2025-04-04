import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:repathy/src/component/notification/comments/comments_bottom_sheet.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_model/media_model.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';
import 'package:repathy/src/util/enum/role_enum.dart';
import 'package:repathy/src/theme/styles.dart';

class MediaPdfDetails extends ConsumerWidget {
  const MediaPdfDetails({super.key, required this.currentUser, required this.result, required this.currentMedia});

  final File result;
  final UserModel currentUser;
  final MediaModel currentMedia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: PageDescriptionText(title: currentMedia.title ?? currentMedia.painEnum.first.name),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(RepathyStyle.roundedRadius),
                          topRight: Radius.circular(RepathyStyle.roundedRadius),
                        ),
                        child: Container(
                          color: RepathyStyle.backgroundColor,
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: CommentsBottomSheet(),
                        ),
                      ),
                      isScrollControlled: true,
                      isDismissible: true,
                    );
                  },
                  icon: Icon(Icons.comment_rounded, color: RepathyStyle.primaryColor, size: RepathyStyle.standardIconSize),
                ),
                if (currentUser.role == RoleEnum.therapist) ...[
                  IconButton(
                    onPressed: () async {
                      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async =>result.readAsBytes());
                    },
                    icon: Icon(Icons.print_outlined, color: RepathyStyle.primaryColor, size: RepathyStyle.standardIconSize),
                  ),
                ],
              ],
            ),
          ],
        ),
        SizedBox(height: 400, child: PDFView(filePath: result.path)),
      ],
    );
  }
}
