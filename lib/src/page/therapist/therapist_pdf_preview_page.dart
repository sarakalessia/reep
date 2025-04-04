import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/controller/current_page_controller/current_page_controller.dart';
import 'package:repathy/src/controller/exercise_controller/exercise_controller.dart';
import 'package:repathy/src/controller/exercise_list_controller/exercise_list_controller.dart';
import 'package:repathy/src/controller/form_controller/form_controller.dart';
import 'package:repathy/src/controller/media_controller/media_controller.dart';
import 'package:repathy/src/controller/pain_controller/pain_controller.dart';
import 'package:repathy/src/controller/pdf_preview_controller/pdf_preview_controller.dart';
import 'package:repathy/src/util/enum/page_enum.dart';
import 'package:repathy/src/util/helper/snackbar/snackbar.dart';

class TherapistPdfPreviewPage extends ConsumerStatefulWidget {
  const TherapistPdfPreviewPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TherapistPdfPreviewPageState();
}

class _TherapistPdfPreviewPageState extends ConsumerState<TherapistPdfPreviewPage> {
  @override
  Widget build(BuildContext context) {
    final pdfPreviewController = ref.watch(pdfPreviewControllerProvider);
    final mediaController = ref.watch(mediaControllerProvider);
    ref.watch(exerciseComponentListControllerProvider);
    ref.watch(painControllerProvider);

    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(children: [PageTitleText(title: 'Anteprima')]),
            Row(children: [PageDescriptionText(title: 'Controlla l\'anteprima prima di stamparlo')]),
            SizedBox(height: 20),
            pdfPreviewController.when(
              data: (File data) {
                return Column(
                  children: [
                    SizedBox(
                      height: 450,
                      child: PDFView(filePath: data.path),
                    ),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),
                    PrimaryButton(
                      text: 'Avanti',
                      onPressed: () async {
                        // SET LOADING STATE
                        ref.read(formControllerProvider.notifier).setStateToFalse();

                        // SAVE MEDIA TO FIRESTORE AND STORAGE
                        final createdMedia = await ref.read(mediaControllerProvider.notifier).saveMediaToFirestoreAndStorage(data, mediaController);
                        debugPrint('View: PDF media saved is: $createdMedia');
                        await ref.read(exerciseControllerProvider.notifier).createExerciseListAndLinkToMedia(mediaId: createdMedia.data!.id!);

                        // UNLOAD UNUSED PROVIDERS
                        ref.invalidate(painControllerProvider);
                        ref.invalidate(exerciseComponentListControllerProvider);

                        // RESTORE LOADING STATE AND NAVIGATE
                        ref.read(formControllerProvider.notifier).setStateToTrue();
                        ref.read(subPageControllerProvider.notifier).navigateToSubPage(index: 2, subPage: PageEnum.linkMediaToPatient);

                        if (context.mounted) ref.read(snackBarProvider(text: 'PDF creato con successo!', successOrFail: true).future);
                      },
                    ),
                  ],
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Il PDF non è stato generato')),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
