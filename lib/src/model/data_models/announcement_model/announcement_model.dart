import 'package:freezed_annotation/freezed_annotation.dart';

part 'announcement_model.freezed.dart';
part 'announcement_model.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class AnnouncementModel with _$AnnouncementModel {
  const factory AnnouncementModel({
    String? id,
    String? senderId, // if this is null it means REPATHY sent the announcement
    String? content,
    String? title,
    String? pathDestination, // announcements may contain a URL to an external page
    DateTime? sentAt,
    DateTime? deletedAt,
    @Default([])List<String> receiverIds,
  }) = _AnnouncementModel;

  factory AnnouncementModel.fromJson(Map<String, Object?> json) => _$AnnouncementModelFromJson(json);
}