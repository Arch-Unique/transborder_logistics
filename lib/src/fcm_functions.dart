import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

class FCMFunctions {
  static final FCMFunctions _singleton = FCMFunctions._internal();

  FCMFunctions._internal();

  factory FCMFunctions() {
    return _singleton;
  }

  late FirebaseMessaging messaging;

//************************************************************************************************************ */
  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//************************************************************************************************************ */

  Future initApp() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    messaging = FirebaseMessaging.instance;

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      //for IOS Foreground Notification
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future subscripeToTopics(String topic) async {
    await messaging.subscribeToTopic(topic);
  }

  ///Expire : https://firebase.google.com/docs/cloud-messaging/manage-tokens
  Future<String?> getFCMToken() async {
    final fcmToken = await messaging.getToken();
    return fcmToken;
  }

  void tokenListener() {
    messaging.onTokenRefresh.listen((fcmToken) {
    }).onError((err) {
      //do something
    });
  }

  /// IOS
  Future iosWebPermission() async {
    if (Platform.isIOS || kIsWeb) {
     await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
  }

  ///Foreground messages
  ///
  ///To handle messages while your application is in the foreground, listen to the onMessage stream.
  void foreGroundMessageListener() {
    FirebaseMessaging.onMessage.listen(onNotifPressed);

    FirebaseMessaging.onMessageOpenedApp.listen(onNotifPressed);
  }

  void listenToNotif(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            icon: "@mipmap/ic_launcher",
          ),
        ),
      );
    }

    print(message.toMap());
  }

  onNotifPressed(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            icon: "@mipmap/ic_launcher",
          ),
        ),
      );
    }

    // final controller = Get.find<DashboardController>();
    // await controller.refreshFinance();
  }
}

final fcmFunctions = FCMFunctions();
