import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

part 'instance.g.dart';

@Riverpod(keepAlive: true)
SharedPreferencesAsync sharedPreferences(Ref ref) => SharedPreferencesAsync();

@Riverpod(keepAlive: true)
FlutterLocalNotificationsPlugin flutterLocalNotificationsInstance(Ref ref) => FlutterLocalNotificationsPlugin();

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuthInstance(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
FirebaseStorage firebaseStorageInstance(Ref ref) => FirebaseStorage.instance;

@Riverpod(keepAlive: true)
FirebaseFirestore firestoreInstance(Ref ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
FirebaseMessaging firebaseMessagingInstance(Ref ref) => FirebaseMessaging.instance;

@Riverpod(keepAlive: true)
FirebaseAppCheck firebaseAppCheckInstance(Ref ref) => FirebaseAppCheck.instance;

@Riverpod(keepAlive: true)
FirebaseCrashlytics firebaseCrashlyticsInstance(Ref ref) => FirebaseCrashlytics.instance;

@Riverpod(keepAlive: true)
InAppPurchase inAppPurchaseInstance(Ref ref) => InAppPurchase.instance;

@riverpod
throwException(Ref ref) => throw Exception('ExceptionProvider is called'); // TEST ONLY
