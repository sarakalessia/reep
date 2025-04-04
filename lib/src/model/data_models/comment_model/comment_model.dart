import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class CommentModel with _$CommentModel {
  const factory CommentModel({
    String? id,
    String? authorId,
    String? mediaId, // PDF or Video where the comment was left 
    DateTime? createdAt,
    DateTime? readAt, // This is when the author of the media has read it 
    DateTime? deletedAt,
    String? content,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, Object?> json) => _$CommentModelFromJson(json);
}