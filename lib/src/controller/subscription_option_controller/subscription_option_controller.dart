import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_option_controller.g.dart';

@riverpod
class SubscriptionOptionController extends _$SubscriptionOptionController {
  @override
  List<bool> build() => <bool>[false, false];

  void changeLoginOption(int index) {
    if (state[index]) {
      state = List.from(state)..[index] = false;
      return;
    }

    state = List.generate(state.length, (i) => i == index);
  }
}

@riverpod
bool isAnySubscriptionOptionselected(Ref ref) {
  final subscriptionOptionController = ref.watch(subscriptionOptionControllerProvider);
  return subscriptionOptionController.any((element) => element);
}

@riverpod
int indexOfSelectedSubscriptionOption(Ref ref) {
  final subscriptionOptionController = ref.watch(subscriptionOptionControllerProvider);
  return subscriptionOptionController.indexWhere((element) => element);
}

@riverpod
class IsSubscriptionOptionLoading extends _$IsSubscriptionOptionLoading {
  @override
  bool build() => false;

  setToLoading() => state = true;
  setToNotLoading() => state = false;
}

// THIS IS ONLY USED FOR GROUP SUBSCRIPTIONS, WHERE A USER HAS TO TYPE A LICENSE CODE
// TODO: IMPLEMENT THIS IN THE FUTURE
@riverpod
class CurrentLicenseCodeController extends _$CurrentLicenseCodeController {
  @override
  String? build() => null;

  void changeCurrentLicense(String? license) => state = license;
}
