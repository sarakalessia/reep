import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bottom_sheet_controller.g.dart';

@riverpod
class BottomSheetcontroller extends _$BottomSheetcontroller {
  @override
  bool build() => false;

  void setToFalse() => state = false;
  void setToTrue() => state = true;
}