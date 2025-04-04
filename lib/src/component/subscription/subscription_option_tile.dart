import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/subscription_option_controller/subscription_option_controller.dart';
import 'package:repathy/src/theme/styles.dart';

class SubscriptionOptionTile extends ConsumerStatefulWidget {
  const SubscriptionOptionTile({super.key, required this.index, required this.title});

  final String title;
  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SubscriptionOptionTileState();
}

class _SubscriptionOptionTileState extends ConsumerState<SubscriptionOptionTile> {
  final licenseCodeController = TextEditingController();

  @override
  void dispose() {
    licenseCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionOptionController = ref.watch(subscriptionOptionControllerProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: widget.index == 2 && subscriptionOptionController[widget.index] == true ? 135 : 70,
        width: MediaQuery.sizeOf(context).width * 0.85,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RepathyStyle.roundedRadius),
                  side: BorderSide(color: RepathyStyle.borderColor, width: 1.5),
                ),
                tileColor: RepathyStyle.backgroundColor,
                title: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 0, 16),
                  child: Text(
                    widget.title,
                    style: TextStyle(fontWeight: RepathyStyle.semiBoldFontWeight),
                  ),
                ),
                subtitle: widget.index == 1 && subscriptionOptionController[widget.index] == true
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                        child: TextFormField(
                          controller: licenseCodeController,
                          style: TextStyle(
                            color: RepathyStyle.darkTextColor,
                            fontSize: RepathyStyle.standardTextSize,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Es: 385821',
                            labelStyle: TextStyle(color: RepathyStyle.lightTextColor, fontSize: RepathyStyle.standardTextSize),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(RepathyStyle.lightRadius),
                              borderSide: BorderSide(color: RepathyStyle.lightBorderColor, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(RepathyStyle.lightRadius),
                              borderSide: BorderSide(color: RepathyStyle.primaryColor, width: 1.0),
                            ),
                          ),
                          onChanged: (value) => ref.read(currentLicenseCodeControllerProvider.notifier).changeCurrentLicense(value),
                        ),
                      )
                    : null,
                trailing: IconButton(
                  icon: Container(
                    width: RepathyStyle.standardIconSize,
                    height: RepathyStyle.standardIconSize,
                    decoration: BoxDecoration(
                      color: subscriptionOptionController[widget.index] == true ? RepathyStyle.primaryColor : RepathyStyle.backgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: RepathyStyle.primaryColor,
                        width: 1.0, 
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        subscriptionOptionController[widget.index] == true ? Icons.check : null,
                        size: RepathyStyle.standardIconSize - 4, 
                        color: RepathyStyle.backgroundColor,
                      ),
                    ),
                  ),
                  onPressed: () => ref.read(subscriptionOptionControllerProvider.notifier).changeLoginOption(widget.index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
