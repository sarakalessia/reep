import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repathy/src/util/enum/pain_enum.dart';

part 'pain_component_model.freezed.dart';
part 'pain_component_model.g.dart';

@freezed
abstract class PainComponentModel with _$PainComponentModel {
  const factory PainComponentModel({
    String? path,
    String? selectedPath, 
    @Default(false) bool isSelected,
    @Default(PainEnum.other) PainEnum painRegion,
  }) = _PainComponentModel;

  factory PainComponentModel.fromJson(Map<String, Object?> json) => _$PainComponentModelFromJson(json);
}
