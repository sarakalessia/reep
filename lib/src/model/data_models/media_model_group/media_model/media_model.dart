import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repathy/src/model/data_models/media_model_group/media_interaction_model/media_interaction_model.dart';
import 'package:repathy/src/util/enum/media_format_enum.dart';
import 'package:repathy/src/util/enum/pain_enum.dart';

part 'media_model.freezed.dart';
part 'media_model.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class MediaModel with _$MediaModel {
  const factory MediaModel({
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? id,
    String? therapistId,
    String? mediaPath, // This allows us to access the URL that contains the file directly
    String? storageUid, // This allows us to delete the file from storage
    String? title,
    @Default(true) bool isPublished,
    @Default(<MediaInteractionModel>[]) List<MediaInteractionModel> mediaInteractions, // All interactions with this media
    @Default(<String>[]) List<String> commentIds, // Used to fetch from the comments collection
    @Default(<String>[]) List<String> patientIds, // Users who have received this media
    @Default(<PainEnum>[]) List<PainEnum> painEnum, // May become a List<PainModel> in the future
    @Default(MediaFormatEnum.unknown) MediaFormatEnum mediaFormat,
  }) = _MediaModel;

  factory MediaModel.fromJson(Map<String, Object?> json) => _$MediaModelFromJson(json);
}