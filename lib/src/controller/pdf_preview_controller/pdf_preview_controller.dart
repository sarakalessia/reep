import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/exercise_list_controller/exercise_list_controller.dart';
import 'package:repathy/src/controller/user_controller/user_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pdf_preview_controller.g.dart';

@riverpod
FutureOr<File> pdfPreviewController(Ref ref) async {
  final pdf = pw.Document();
  final exerciseListController = ref.read(exerciseComponentListControllerProvider);
  final currentUser = ref.read(userControllerProvider);
  final fontRegular = pw.Font.ttf(await rootBundle.load('assets/pdf_fonts/Roboto-Regular.ttf'));
  final fontBold = pw.Font.ttf(await rootBundle.load('assets/pdf_fonts/Roboto-Bold.ttf'));
  final img = await rootBundle.load('assets/logo/ios_icon_transparent.png');
  final imageBytes = img.buffer.asUint8List();
  final logo = pw.Image(pw.MemoryImage(imageBytes), width: 40, height: 40);


  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Esercizi domiciliari',
                  style: pw.TextStyle(font: fontBold, fontSize: 14),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Fisioterapista ${currentUser?.name ?? 'N/A'}',
                  style: pw.TextStyle(font: fontBold, fontSize: 14),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${currentUser?.name ?? 'N/A'} ${currentUser?.lastName ?? 'N/A'}', style: pw.TextStyle(font: fontRegular, fontSize: 12)),
                pw.Text('${currentUser?.studioName ?? 'Nome dello studio non definito.'}', style: pw.TextStyle(font: fontRegular, fontSize: 12)),
                pw.Text('${currentUser?.addressString ?? 'Indirizzo non definito.'}', style: pw.TextStyle(font: fontRegular, fontSize: 12)),
                pw.Text('${currentUser?.phoneNumber ?? 'Numero di telefono non definito.'}', style: pw.TextStyle(font: fontRegular, fontSize: 12)),
                pw.Text('${currentUser?.email ?? 'Email non definita.'}', style: pw.TextStyle(font: fontRegular, fontSize: 12)),
              ],
            ),
          ],
        ),
        ...exerciseListController.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final exercise = entry.value;
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),
              pw.Text('Esercizio $index', style: pw.TextStyle(font: fontBold, fontSize: 18)),
              pw.Text(exercise.exerciseModel?.title ?? '', style: pw.TextStyle(font: fontRegular, fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Wrap(
                spacing: 10,
                runSpacing: 10,
                children: exercise.images.map((file) {
                  final image = pw.MemoryImage(file.readAsBytesSync());
                  return pw.Image(image, width: 100, height: 100);
                }).toList(),
              ),
              pw.SizedBox(height: 10),
              pw.Text(exercise.exerciseModel?.description ?? '', style: pw.TextStyle(font: fontRegular, fontSize: 14)),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.Text('Serie: ${exercise.exerciseModel?.sets ?? 'N/A'}', style: pw.TextStyle(font: fontRegular, fontSize: 14)),
                  pw.SizedBox(width: 20),
                  pw.Text('Repetizioni: ${exercise.exerciseModel?.repetitions ?? 'N/A'}', style: pw.TextStyle(font: fontRegular, fontSize: 14)),
                ],
              ),
            ],
          );
        }),
      ],
      footer: (context) => pw.Container(
        alignment: pw.Alignment.center,
        margin: pw.EdgeInsets.only(top: 20),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              logo,
              pw.Text('Documento realizzato con Repathy', style: pw.TextStyle(font: fontRegular, fontSize: 12)),
            ]
        ),
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/example.pdf");
  await file.writeAsBytes(await pdf.save());
  return file;
}
