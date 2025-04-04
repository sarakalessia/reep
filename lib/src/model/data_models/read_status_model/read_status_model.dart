import 'package:freezed_annotation/freezed_annotation.dart';

part 'read_status_model.freezed.dart';
part 'read_status_model.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class ReadAtModel with _$ReadAtModel {
  const factory ReadAtModel({
    String? readerId,
    DateTime? readAt,
  }) = _ReadAtModel;

  factory ReadAtModel.fromJson(Map<String, Object?> json) => _$ReadAtModelFromJson(json);
}