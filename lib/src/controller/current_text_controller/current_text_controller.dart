import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_text_controller.g.dart';

@riverpod
class CurrentTextController extends _$CurrentTextController {
  @override
  String build() => '';

   clearText() => state = '';
   updateText(String text) => state = text;
}