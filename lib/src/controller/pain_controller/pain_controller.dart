import 'package:repathy/src/model/component_models/pain_component_model/pain_component_model.dart';
import 'package:repathy/src/util/constant/pain_list_const.dart';
import 'package:repathy/src/util/enum/pain_enum.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pain_controller.g.dart';

@Riverpod(keepAlive: true)
class PainController extends _$PainController {
  @override
  List<PainComponentModel> build() {
    return painPathList.entries.map((entry) {
      final PainEnum painEnumKey = entry.key;
      return PainComponentModel(
        path: entry.value, // Unselected path
        selectedPath: painPathSelectedList[painEnumKey], // Selected path from the new map
        painRegion: painEnumKey,
      );
    }).toList();
  }

  // STATE

  void togglePainSelection(int index) {
    state = state.map((e) {
      if (e == state[index]) {
        return e.copyWith(isSelected: !e.isSelected);
      }
      return e;
    }).toList();
  }

  void updateSelectedPainFromPainEnumList(List<PainEnum> painEnumList) {
    state = state.map((e) {
      if (painEnumList.contains(e.painRegion)) {
        return e.copyWith(isSelected: true);
      }
      return e.copyWith(isSelected: false);
    }).toList();
  }

  // UTILITY

  List<PainEnum> exctractPainEnumListFromState() {
    List<PainEnum> painEnum = state.where((e) => e.isSelected).map((e) => e.painRegion).toList();
    return painEnum;
  }

  String? extractPainPathFromPainEnum(PainEnum? painEnum) {
    if (painEnum == null) return null;
    String? painPath = state.firstWhere((e) => e.painRegion == painEnum).path; // Still returns unselected path by default
    return painPath;
  }

  String? extractSelectedPainPathFromPainEnum(PainEnum? painEnum) { // New utility method to get selected path
    if (painEnum == null) return null;
    String? selectedPainPath = state.firstWhere((e) => e.painRegion == painEnum).selectedPath;
    return selectedPainPath;
  }
}

@riverpod
class CurrentPainController extends _$CurrentPainController {
  @override
  PainEnum build() => PainEnum.other;

  void updateCurrentPain(PainEnum painEnum) => state = painEnum;
  void clearCurrentPain() => state = PainEnum.other;
}
