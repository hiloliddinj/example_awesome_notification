import 'package:example_awesome_notification/navigation_page.dart';
import 'package:example_awesome_notification/screen_one.dart';
import 'package:example_awesome_notification/screen_two.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'home_page.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  String defaultImageLink = 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/2560px-Image_created_with_a_mobile_phone.png';
  print("HHHHH==> Handling a background message: ${message.data}");
  // AwesomeNotifications().createNotificationFromJsonData(message.data);

  Map<String, String> payloadFromData =
  message.data.map((key, value) => MapEntry(key, value?.toString() ?? "NO DATA!"));

  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'my_test_not_id',
      title: message.notification?.title ?? "No Title",
      body: message.notification?.title ?? "No Body",
      bigPicture: message.data['url'] ?? defaultImageLink,
      notificationLayout: NotificationLayout.BigPicture,
      payload: payloadFromData,
    ),
  );

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'my_test_not_id',
        channelName: 'My Channel Name',
        channelDescription: 'Notification Example',
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        defaultColor: const Color(0XFF9050DD),
        ledColor: Colors.white,
        playSound: true,
        soundSource: 'resource://raw/my_sound',
        enableLights: true,
        enableVibration: true,
      ),
    ],
  );
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal)
              .copyWith(secondary: Colors.tealAccent)),
      home: const HomePage(),
      routes: {
        NavigationPage.route : (context) => const NavigationPage(),
        ScreenOne.route : (context) => const ScreenOne(),
        ScreenTwo.route : (context) => const ScreenTwo(),
      },
    );
  }
}

