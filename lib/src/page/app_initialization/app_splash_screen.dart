import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repathy/route/route.dart';
import 'package:repathy/src/page/app_initialization/app_error_widget.dart';
import 'package:repathy/src/controller/app_initialization_controller/app_initialization.dart';
import 'package:repathy/src/theme/styles.dart';

class AppSplashPage extends ConsumerWidget {
  const AppSplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStartupState = ref.watch(appInitializationProvider);

    return appStartupState.when(
      data: (_) {
        Future.microtask(() => ref.read(goRouterProvider).go('/'));
        return _returnSplashScreen(context);
      },
      error: (Object obj, StackTrace st) => AppErrorPage(obj: obj, st: st),
      loading: () => _returnSplashScreen(context),
    );
  }

  Widget _returnSplashScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      body: FlutterSplashScreen(
        useImmersiveMode: true,
        splashScreenBody: Center(
          child: Image.asset(
            'assets/logo/ios_icon_transparent.png',
            width: 250,
            height: 233,
          ),
        ),
        backgroundColor: RepathyStyle.backgroundColor,
      ),
    );
  }
}
