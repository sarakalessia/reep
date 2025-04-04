import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'url_launcher.g.dart';

@riverpod
FutureOr<void> launchBrowserUrl(Ref ref, String urlToLaunch) async {
  final Uri url = Uri.parse(urlToLaunch);
  debugPrint('Service: launchSomeUrl is called with url: $url');
  if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
}
