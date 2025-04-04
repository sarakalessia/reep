import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/component/button/primary_button.dart';
import 'package:repathy/src/component/text/page_description_text.dart';
import 'package:repathy/src/component/text/page_title_text.dart';
import 'package:repathy/src/controller/subscription_controller/subscription_controller.dart';
import 'package:repathy/src/model/data_models/result_model/result_model.dart';
import 'package:repathy/src/model/data_models/subscription_model/subscription_model.dart';
import 'package:repathy/src/theme/styles.dart';

class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(getCurrentUserSubscriptionProvider);

    return Flexible(
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: Align(alignment: Alignment.centerLeft, child: PageTitleText(title: 'Licenza')),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Align(alignment: Alignment.centerLeft, child: PageDescriptionText(title: 'Licenza attiva')),
              ),
            ],
          ),
          subscription.when(
              data: ( (ResultModel<SubscriptionModel>, ResultModel<SubscriptionModel>) data) {
                final patintSubscription = data.$1.data;
                final therapistSubscription = data.$2.data;
                final currentSubscription = patintSubscription ?? therapistSubscription;                

                if (currentSubscription == null) return Center(child: Text('Licenza non trovata'));

                final subscriptionDurationTitle = currentSubscription.realEndDate!.difference(DateTime.now()).inDays < 30 ? 'Mensile' : 'Annuale';
                final oppositeSubscriptionDurationTitle = currentSubscription.realEndDate!.difference(DateTime.now()).inDays < 30 ? 'annuale' : 'mensile';

                return Column(
                  children: [
                    Container(
                      height: 70,
                      padding: EdgeInsets.fromLTRB(16, 12, 0, 12),
                      margin: EdgeInsets.fromLTRB(0, 12, 0, 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: RepathyStyle.lightTextColor, width: 1),
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: RepathyStyle.secondaryColor,
                            child: Icon(Icons.check, color: Colors.white, size: RepathyStyle.miniIconSize),
                          ),
                          SizedBox(width: 12),
                          PageDescriptionText(title: subscriptionDurationTitle)
                        ],
                      ),
                    ),
                    Text('Scade automaticamente e si rinnova il 5 del mese', style: TextStyle(fontSize: RepathyStyle.miniTextSize)),
                    RichText(
                      text: TextSpan(
                        text: 'Vuoi passare all’abbonamento $oppositeSubscriptionDurationTitle? ',
                        style: TextStyle(fontSize: RepathyStyle.miniTextSize, color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Clicca qui',
                            style: TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                              },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 70,
                      padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                      margin: EdgeInsets.fromLTRB(0, 24, 0, 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: RepathyStyle.lightTextColor, width: 1),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rinnovo automatico',
                            style: TextStyle(fontSize: RepathyStyle.smallTextSize),
                          ),
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: RepathyStyle.secondaryColor,
                            child: Icon(Icons.check, color: Colors.white, size: RepathyStyle.miniIconSize),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => standardDialog(
                          context,
                          'Annulla abbonamento',
                          'Sei sicuro di voler annullare l’abbonamento?',
                          'Annulla',
                          () async => await ref.read(subscriptionControllerProvider.notifier).expireSubscription(null),
                        ),
                      ),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          border: Border.all(color: RepathyStyle.primaryColor, width: 1),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child:
                              Text('Annulla abbonamento', style: TextStyle(color: RepathyStyle.primaryColor, fontSize: RepathyStyle.smallTextSize)),
                        ),
                      ),
                    ),
                  ],
                );
              },
              error: (error, stackTrace) => PageDescriptionText(title: 'Non ci sono video'),
              loading: () => CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget standardDialog(BuildContext context, String title, String content, String buttonTitle, Function() onPressed) {
    return AlertDialog(
      icon: Align(
        alignment: Alignment.centerRight,
        child: IconButton(onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.close)),
      ),
      // title: PageTitleText(title: title),
      content: PageDescriptionText(title: content),
      actions: [
        PrimaryButton(
          onPressed: () async {
            await onPressed();
            if (context.mounted) Navigator.of(context).pop();
          },
          text: buttonTitle,
        ),
      ],
    );
  }
}
