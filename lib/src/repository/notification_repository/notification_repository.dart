import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:repathy/src/util/instance/instance.dart';
import 'package:repathy/src/repository/user_repository/user_repository.dart';
import 'package:repathy/src/util/helper/environment_config/environment_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'notification_repository.g.dart';

@riverpod
class NotificationsRepository extends _$NotificationsRepository {
  @override
  void build() {}

  Future<bool> notifySingleUser(String userId, String content, String title) async {
    debugPrint("Repository: notifySingleUser is called with userId: $userId, content: $content, title: $title");

    final http.Response response;
    final dynamic decodedResponse;
    final String body;
    final String endpointUrl = ref.read(environmentConfigProvider).requireValue['NOTIFY_SINGLE_USER_URL'] ?? '';
    final Uri uri = Uri.parse(endpointUrl);

    final userFcmResult = await ref.read(userRepositoryProvider.notifier).getFirebaseMessagingId(userId);
    final userFcmId = userFcmResult.data;

    if (userFcmId == null) return false;

    final String? appCheckToken = await ref.read(firebaseAppCheckInstanceProvider).getToken();

    if (appCheckToken == null) return false;

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "X-Firebase-AppCheck": appCheckToken,
    };

    try {
      body = json.encode({
        'userFcmId': userFcmId,
        'title': title,
        'description': content,
      });

      response = await http.post(uri, headers: headers, body: body);

      decodedResponse = jsonDecode(response.body);

      debugPrint("Repository: notifySingleUser decodedResponse is $decodedResponse");

      if (decodedResponse['success'] == true) return true;

      return false;
    } catch (e) {
      debugPrint("Repository: notifySingleUser error is: $e");
      return false;
    }
  }

  Future<bool> notifyUserGroup(List<String> userIdList, String content, String title) async {
    debugPrint("Repository: notifyUserGroup is called with userIdList: $userIdList, content: $content, title: $title");

    final http.Response response;
    final dynamic decodedResponse;
    final String body;
    final String endpointUrl = ref.read(environmentConfigProvider).requireValue['NOTIFY_USER_GROUP_URL'] ?? '';
    final Uri uri = Uri.parse(endpointUrl);

    final List<String> userFcmIdList = await ref.read(userRepositoryProvider.notifier).getListOfFirebaseMessagingId(userIdList);

    if (userFcmIdList.isEmpty) return false;

    final String? appCheckToken = await ref.read(firebaseAppCheckInstanceProvider).getToken();

    if (appCheckToken == null) return false;

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "X-Firebase-AppCheck": appCheckToken,
    };

    try {
      body = json.encode({
        'userList': userFcmIdList,
        'title': title,
        'description': content,
      });

      response = await http.post(uri, headers: headers, body: body);

      decodedResponse = jsonDecode(response.body);

      debugPrint("Repository: notifyUserGroup decodedResponse is $decodedResponse");

      if (response.statusCode == 200) {
        return decodedResponse['success'] == true;
      } else {
        debugPrint("Repository: notifyUserGroup error: ${response.statusCode} ${response.reasonPhrase}");
        return false;
      }
    } catch (e) {
      debugPrint("Repository: notifyUserGroup error is: $e");
      return false;
    }
  }
}
