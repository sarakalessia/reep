import 'package:freezed_annotation/freezed_annotation.dart';

part 'studio_model.freezed.dart';
part 'studio_model.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class StudioModel with _$StudioModel {
  const factory StudioModel({
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? id,
    String? currentSubscriptionId,
    String? studioOwnerId,
    String? studioName,
    String? studioLogoUrl,
    @Default(<String>[]) List<String> subscriptionIdHistory, // all subscriptions a studio has had
    @Default(<String>[]) List<String> linkedUserIds, // all therapists linked to this studio
  }) = _StudioModel;

  factory StudioModel.fromJson(Map<String, Object?> json) => _$StudioModelFromJson(json);
}
