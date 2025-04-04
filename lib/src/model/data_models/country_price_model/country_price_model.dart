import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_price_model.freezed.dart';
part 'country_price_model.g.dart';

@freezed
abstract class CountryPriceModel with _$CountryPriceModel {
  const factory CountryPriceModel({
    required String countryName,
    required double price,
  }) = _CountryPriceModel;

  factory CountryPriceModel.fromJson(Map<String, Object?> json) => _$CountryPriceModelFromJson(json);
}