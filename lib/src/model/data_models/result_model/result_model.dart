import 'package:freezed_annotation/freezed_annotation.dart';

part 'result_model.freezed.dart';

// ATTENTION: THIS IS AN EXPERIMENTAL MODEL
// THE IDEA IS TO START WORKING WITH GENERIC TYPES IN FREEZED

@freezed
abstract class ResultModel<T> with _$ResultModel<T> {
  const factory ResultModel({
    T? data,
    String? error,
  }) = _ResultModel;
}