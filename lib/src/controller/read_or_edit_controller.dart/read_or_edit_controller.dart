import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'read_or_edit_controller.g.dart';

@riverpod
class ReadOrEditController extends _$ReadOrEditController {
  @override
  bool build() => true;

  toggleState() => state = !state;
}