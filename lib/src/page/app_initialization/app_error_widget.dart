import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/src/controller/app_initialization_controller/app_initialization.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppErrorPage extends ConsumerStatefulWidget {
  const AppErrorPage({super.key, this.obj, this.st});

  final Object? obj;
  final StackTrace? st;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppErrorPageState();
}

class _AppErrorPageState extends ConsumerState<AppErrorPage> {

  @override
  void initState() {
    debugPrint('AppErrorPage: obj: ${widget.obj}, st: ${widget.st}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => ref.invalidate(appInitializationProvider),
          child: Text(AppLocalizations.of(context)!.appFailed),
        ),
      ),
    );
  }
}
