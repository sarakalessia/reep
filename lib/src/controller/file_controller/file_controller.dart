import 'dart:io';
import 'package:repathy/src/util/enum/media_format_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_controller.g.dart';

@Riverpod(keepAlive: true)
class CurrentFileController extends _$CurrentFileController {
  @override
  File? build() => null;

  setFile(File file) => state = file;
  clearFile() => state = null;
  invalidateFileController() => ref.invalidateSelf();

  MediaFormatEnum getMediaFormat() {
    if (state == null) return MediaFormatEnum.unknown;
    final String path = state!.path;
    if (path.contains('.mp4') || path.contains('.MP4')) return MediaFormatEnum.mp4;
    if (path.contains('.mov') || path.contains('.MOV')) return MediaFormatEnum.mov;
    if (path.contains('.jpeg') || path.contains('.JPEG')) return MediaFormatEnum.jpeg;
    if (path.contains('.png') || path.contains('.PNG')) return MediaFormatEnum.png;
    if (path.contains('.jpg') || path.contains('.JPG')) return MediaFormatEnum.jpg;
    if (path.contains('.heic') || path.contains('.HEIC')) return MediaFormatEnum.heic;
    if (path.contains('.pdf') || path.contains('.PDF')) return MediaFormatEnum.pdf;
    return MediaFormatEnum.unknown;
  }
}
