import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:chat_application/helper/pushNotification.dart';

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void registerNotification(String currentUserId) {
  firebaseMessaging.requestPermission();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('onMessage: $message');
    if (message.notification != null) {
      showNotification(message.notification);
    }
    return;
  });

  firebaseMessaging.getToken().then((token) {
    print('token: $token');
    FirebaseFirestore.instance.collection('users').doc(currentUserId).update({'pushToken': token});
  }).catchError((err) {
    Fluttertoast.showToast(msg: err.message.toString());
  });

  configLocalNotification();
}

void showNotification(RemoteNotification remoteNotification) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    Platform.isAndroid ? 'com.dfa.flutterchatdemo' : 'com.duytq.flutterchatdemo',
    'Flutter chat demo',
    'your channel description',
    playSound: true,
    enableVibration: true,
    importance: Importance.max,
    priority: Priority.high,
  );
  IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
  NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

  print(remoteNotification);

  await flutterLocalNotificationsPlugin.show(
    0,
    remoteNotification.title,
    remoteNotification.body,
    platformChannelSpecifics,
    payload: null,
  );
}

void configLocalNotification() {
  AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
  InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}