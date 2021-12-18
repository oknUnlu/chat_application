import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  push(String title, String message) async {
    FlutterLocalNotificationsPlugin localNotificationsPlugin;
    var androidInitialize = new AndroidInitializationSettings('flutter_logo');
    var iOSInitialize = new IOSInitializationSettings();
    var initializeSettings =
        new InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

    localNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    localNotificationsPlugin.initialize(initializeSettings);

    var androidDetails = new AndroidNotificationDetails(
        "channelId",
        "Local Notification",
        "This is the description of the Notification, you can write anything",
        importance: Importance.high);
    var iosDetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iosDetails);
    await localNotificationsPlugin.show(0, title, message, generalNotificationDetails);
  }
}