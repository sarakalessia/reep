import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repathy/src/model/data_models/user_model/user.dart';

part 'user_component_model.freezed.dart';
part 'user_component_model.g.dart';

@freezed
abstract class UserComponentModel with _$UserComponentModel {
  const factory UserComponentModel({
    @Default(false) bool isSelected,
    UserModel? userModel,
  }) = _UserComponentModel;

  factory UserComponentModel.fromJson(Map<String, Object?> json) => _$UserComponentModelFromJson(json);
}