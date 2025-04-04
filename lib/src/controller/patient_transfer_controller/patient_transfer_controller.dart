import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'patient_transfer_controller.g.dart';

@riverpod
class PatientTransferController extends _$PatientTransferController {
  @override
  bool build(int step) => false;

  toggleState() => state = !state;
}