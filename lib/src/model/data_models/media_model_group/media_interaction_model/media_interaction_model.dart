import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repathy/src/util/enum/media_format_enum.dart';

part 'media_interaction_model.freezed.dart';
part 'media_interaction_model.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class MediaInteractionModel with _$MediaInteractionModel {
  const factory MediaInteractionModel({
    String? id,
    String? mediaId,
    String? patientId, // ID of the user who played the media,
    DateTime? openedAt, // Only for Videos
    DateTime? stoppedAt, // Only stores the first stop time
    @Default(false) bool hasConcluded, // If the user has watched the video to the end
    @Default(MediaFormatEnum.unknown) MediaFormatEnum mediaFormat,
  }) = _MediaInteractionModel;

  factory MediaInteractionModel.fromJson(Map<String, Object?> json) => _$MediaInteractionModelFromJson(json);
}