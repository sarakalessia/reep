import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repathy/src/util/enum/pain_enum.dart';

part 'pain_model.freezed.dart';
part 'pain_model.g.dart';

@freezed
abstract class PainModel with _$PainModel {
  const factory PainModel({
    DateTime? dateStarted,
    @Default(PainLevelEnum.unknown) PainLevelEnum painLevel,
    @Default(PainEnum.other) PainEnum painRegion,
  }) = _PainModel;

  factory PainModel.fromJson(Map<String, Object?> json) => _$PainModelFromJson(json);
}