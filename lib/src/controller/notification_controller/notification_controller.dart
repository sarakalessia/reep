import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notification_controller.g.dart';

@riverpod
Future<void> initNotificationController(Ref ref) async => await NotificationController().initNotifications();

class NotificationController {
  NotificationController._privateConstructor() {
    debugPrint('Service: NotificationController private constructor called');
  }

  static final NotificationController _instance = NotificationController._privateConstructor();

  factory NotificationController() {
    debugPrint('Service: NotificationController factory constructor called');
    return _instance;
  }

  final firebaseMessagingInstance = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool isFlutterLocalNotificationsInitialized = false;

  Future<void> initNotifications() async {
    debugPrint('Service: initNotifications called');
    try {
      await _setPermissions();
      await _getToken();
      await _setupFlutterNotifications();
      await _startAppFromClosedState();
      await _handleForegroundNotifications();
    } catch (e) {
      debugPrint('Service: NotificationController initNotifications error is $e');
    }
  }

  // STEP 1: Request permission
  Future<void> _setPermissions() async {
    debugPrint('Service: _setPermissions called');
    NotificationSettings notificationSettings = await firebaseMessagingInstance.requestPermission(
      alert: true,
      sound: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      announcement: false,
    );

    if (notificationSettings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Service: Notifications authorized');
    } else if (notificationSettings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Service: Notifications denied');
      // Optionally, handle the case where the user denies permissions
    } else if (notificationSettings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('Service: Provisional authorization granted');
      // Handle provisional permissions if needed
    }
    debugPrint('Service: _setPermissions completed with status ${notificationSettings.toString()}');
  }

  // STEP 2: Get token
  Future<void> _getToken() async {
    debugPrint('Service: _getToken called');
    String? token;
    SharedPreferencesAsync instance = SharedPreferencesAsync();

    token = await firebaseMessagingInstance.getToken();
    if (token != null) {
      await instance.setString('fcm_token', token);
      debugPrint('Service: initial fcm_token is $token');
    }

    firebaseMessagingInstance.onTokenRefresh.listen((String refreshToken) async {
      debugPrint('Service: onTokenRefresh called with token $refreshToken');
      token = refreshToken;
      await instance.setString('fcm_token', refreshToken);
    });

    if (Platform.isIOS) await FirebaseMessaging.instance.getAPNSToken();

    debugPrint('Service: _getToken completed');
  }

  // STEP 3: Initialize local notifications
  Future<void> _setupFlutterNotifications() async {
    debugPrint('Service: _setupFlutterNotifications called');
    if (isFlutterLocalNotificationsInitialized) {
      debugPrint('Service: FlutterLocalNotifications already initialized');
      return;
    }

   AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: darwinInitSettings,
    );

    debugPrint('Service: _setupFlutterNotifications initSettings is ${initSettings.toString()}');

    await flutterNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint(
            'Service: _setupFlutterNotifications onDidReceiveNotificationResponse called with payload: ${details.payload}');
      },
    );

    await flutterNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel)
        .then((_) => debugPrint('Service:  _setupFlutterNotifications notification channel created'))
        .catchError((error) => debugPrint('Error creating notification channel: $error'));

    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          )
          .then((_) => debugPrint('Service: _setupFlutterNotifications foreground notifications set'))
          .catchError((error) => debugPrint('Error setting foreground notification options: $error'));
    }

    isFlutterLocalNotificationsInitialized = true;
    debugPrint('Service: _setupFlutterNotifications completed');
  }

  // STEP 4: Bring app from closed state
  Future<void> _startAppFromClosedState() async {
    debugPrint('Service: _startAppFromClosedState called');
    RemoteMessage? initialMessage;

    initialMessage = await firebaseMessagingInstance.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('Service: _startAppFromClosedState initialMessage is not null');
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Service: _startAppFromClosedState onMessageOpenedApp called with message ${message.messageId}');
      _handleMessage(message);
    });
    debugPrint('Service: _startAppFromClosedState completed');
  }

  // STEP 5: Show notifications when in Foreground
  Future<void> _handleForegroundNotifications() async {
    debugPrint('Service: _handleForegroundNotifications called');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint(
          'Service:_handleForegroundNotifications onMessage callback message is ${message.notification?.title} and ${message.notification?.body}');
      await _handleMessage(message);
    });
    debugPrint('Service: _handleForegroundNotifications completed');
  }

  Future<void> _showFlutterNotification(RemoteMessage message) async {
    debugPrint('Service: _showFlutterNotification called with message ${message.messageId}');
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      debugPrint('Service: _showFlutterNotification Showing notification with title ${notification.title}');
      const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        ticker: 'ticker',
      );

      const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );

      await flutterNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: message.data.toString(),
      );
    }
    debugPrint('Service: _showFlutterNotification completed');
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    debugPrint(
        'Service: _handleMessage FirebaseMessageController notification is ${(message.messageId)} with notification ${message.notification.toString()}, ${message.notification?.body} and title ${message.notification?.title} and apple badge ${message.notification?.apple?.badge} and data ${message.data.toString()}');
    if (message.notification != null) await _showFlutterNotification(message);
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Service: firebaseMessagingBackgroundHandler called with message ${message.messageId}');
}
