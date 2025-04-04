import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_formatter.g.dart';

@riverpod
class SubscriptionFormatter extends _$SubscriptionFormatter {
  @override
  void build() {}

  convertV1PlanNamesToShowableNames(String name, bool isTherapist) {
    if (isTherapist) {
      return 'Singola Licenza'; 
    } else {
      return 'Singolo Abbonamento';
    }
  }

  String translateFrequency(String frequency, String baselanguage) {
    switch (frequency) {
      case 'mensile':
        return baselanguage == 'it' ? 'monthly' : 'mensile';
      case 'annuale':
        return baselanguage == 'it' ? 'yearly' : 'annuale';
      default:
        return 'Unknown';
    }
  }
}
