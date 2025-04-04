import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

enum MediaFormatEnum {
  @JsonValue("pdf")
  pdf,
  @JsonValue("heic")
  heic,
  @JsonValue("mp4")
  mp4,
  @JsonValue("mov")
  mov,
  @JsonValue("jpeg")
  jpeg,
  @JsonValue("jpg")
  jpg,
  @JsonValue("png")
  png,
  @JsonValue("unknown")
  unknown,
}

enum StorageFolderEnum {
  @JsonValue("video")
  video,
  @JsonValue("pdf")
  pdf,
  @JsonValue("image")
  image,
  @JsonValue("unknown")
  unknown,
}

extension MediaFormatEnumExtension on MediaFormatEnum {
  StorageFolderEnum get mediaToStorageConverter {
    switch (this) {
      case MediaFormatEnum.pdf:
        debugPrint('MediaFormatEnumExtension case: pdf');
        return StorageFolderEnum.pdf;
      case MediaFormatEnum.heic || MediaFormatEnum.jpeg || MediaFormatEnum.png || MediaFormatEnum.jpg:
        debugPrint('MediaFormatEnumExtension case: image');
        return  StorageFolderEnum.image;
      case MediaFormatEnum.mp4 || MediaFormatEnum.mov:
        debugPrint('MediaFormatEnumExtension case: video');
        return StorageFolderEnum.video;
      case MediaFormatEnum.unknown:
        debugPrint('MediaFormatEnumExtension case: unknown');
        return StorageFolderEnum.unknown;
    }
  }
}