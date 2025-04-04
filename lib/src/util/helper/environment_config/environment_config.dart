import 'dart:convert';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:repathy/src/util/helper/app_mode_provider/app_mode_provider.dart';
import 'package:repathy/src/util/helper/url_provider/url_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'environment_config.g.dart';

@Riverpod(keepAlive: true)
class EnvironmentConfig extends _$EnvironmentConfig {
  @override
  FutureOr<Map<String, String>> build() async {
    debugPrint('Controller: EnvConfig initEnvironment is called');
    final bool env = ref.read(appModeProvider);
    Map<String, String> keys = {};

    if (env == true) keys = await _loadLocalEnvVariables();
    if (env == false) keys = await _fetchFunctionUrlsFromFirestore();

    return keys;
  }

 Future<Map<String, String>> _loadLocalEnvVariables() async {
    debugPrint('Controller: EnvConfig _loadLocalEnvVariables is called');
    await dotenv.load();
    final Map<String, String> keys = {
      'NOTIFY_SINGLE_USER_URL': dotenv.env['NOTIFY_SINGLE_USER_URL'] ?? '',
      'NOTIFY_USER_GROUP_URL': dotenv.env['NOTIFY_USER_GROUP_URL'] ?? '',
      'VERIFY_APPLE_RECEIPT_URL': dotenv.env['VERIFY_APPLE_RECEIPT_URL'] ?? '',
      'VERIFY_ANDROID_RECEIPT_URL': dotenv.env['VERIFY_ANDROID_RECEIPT_URL'] ?? '',
      'PRIVACY_POLICY_URL': dotenv.env['PRIVACY_POLICY_URL'] ?? '',
      'TERMS_OF_SERVICE_URL': dotenv.env['TERMS_OF_SERVICE_URL'] ?? '',
    };
    return keys;
  }

  Future<Map<String, String>> _fetchFunctionUrlsFromFirestore() async {
    debugPrint('Controller: EnvConfig _fetchFunctionUrlsFromFirestore is called');
    final http.Response response;
    final dynamic decodedResponse;
    final String body = json.encode({});
    final String url = ref.read(functionBaseUrlProvider);
    final Uri uri = Uri.parse(url);

    final String? appCheckToken = await FirebaseAppCheck.instance.getToken();

    debugPrint('Controller: EnvConfig _fetchFunctionUrlsFromFirestore appCheckToken is: $appCheckToken');

    if (appCheckToken == null) return <String, String>{};

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "X-Firebase-AppCheck": appCheckToken,
    };

    response = await http.post(uri, headers: headers, body: body);

    decodedResponse = jsonDecode(response.body);

    debugPrint('Controller: EnvConfig _fetchFunctionUrlsFromFirestore decodedResponse is: $decodedResponse');

    final Map<String, String> keys = {
      'NOTIFY_SINGLE_USER': decodedResponse['data']['NOTIFY_SINGLE_USER_URL'] ?? '',
      'NOTIFY_USER_GROUP': decodedResponse['data']['NOTIFY_USER_GROUP_URL'] ?? '',
      'VERIFY_APPLE_RECEIPT_URL': decodedResponse['data']['VERIFY_APPLE_RECEIPT_URL'] ?? '',
      'VERIFY_ANDROID_RECEIPT_URL': decodedResponse['data']['VERIFY_ANDROID_RECEIPT_URL'] ?? '',
      'PRIVACY_POLICY_URL': decodedResponse['data']['PRIVACY_POLICY_URL'] ?? '',
      'TERMS_OF_SERVICE_URL': decodedResponse['data']['TERMS_OF_SERVICE_URL'] ?? '',
    };

    return keys;
  }
}
