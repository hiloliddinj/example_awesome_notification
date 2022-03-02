import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:example_awesome_notification/screen_one.dart';
import 'package:example_awesome_notification/screen_two.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'navigation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  void initState() {
    super.initState();
    handleNotificationPermission();
    firebaseNotificationSettings();
  }

  void handleNotificationPermission() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Allow Notification"),
            content: const Text("Need Permission for Notification"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Don\'t Allow"),
              ),
              TextButton(
                onPressed: () {
                  AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context));
                },
                child: const Text("Allow"),
              ),
            ],
          ),
        );
      }
    });

    FirebaseMessaging.instance.getToken().then((token) {
      print('My Firebase Token: $token');
    });
  }

  void firebaseNotificationSettings() {
    ///Gives you the message on which user taps and it opened the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        //final Map<String, dynamic> myData = message.data;
        //_firebaseMessagingBackgroundHandler(message);
        //notifyFCM(message, "instance");
      }
    });

    ///Foreground work
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print(message.notification!.body ?? "");
        print(message.notification!.title ?? "");
        //_firebaseMessagingBackgroundHandler(message);
        notifyFCM(message, "onMessage");
      }
    });

    ///Background  but app is open state: user taps on notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      //final String link = message.data['link'];
      //final Map<String, dynamic> myData = message.data;
      //_firebaseMessagingBackgroundHandler(message);
      // notifyFCM(message, "onMessageOpenedApp");
    });

    AwesomeNotifications().actionStream.listen((receivedNotification) {
      _navigateToScreen(receivedNotification.payload);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            notifyLocal();
          },
          child: const Icon(Icons.circle_notifications),
        ),
      ),
    );
  }

  void notifyLocal() async {

    // String timeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    // print("HHHHH==> timeZone: $timeZone");

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'my_test_not_id',
        title: 'This is Notification title',
        body: 'This is body of notification',
        bigPicture: 'https://cdn.tutsplus.com/gamedev/uploads/legacy/043_freeShmupSprites/Free_Shmup_Sprites_Boss_Battle.jpg',
        notificationLayout: NotificationLayout.BigPicture,
        payload: {
          'aaa': 'bbb',
          '111': '222',
        },
      ),
      //schedule: NotificationInterval(interval: 5, timeZone: timeZone, repeats: true),
    );
  }


  void notifyFCM(RemoteMessage message, String from) async {
    //print("HHHHH ==> FROM: $from");
    String defaultImageLink = 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/2560px-Image_created_with_a_mobile_phone.png';
    // String timeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    // print("HHHHH==> timeZone: $timeZone");
    //https://cdn.tutsplus.com/gamedev/uploads/legacy/043_freeShmupSprites/Free_Shmup_Sprites_Boss_Battle.jpg

    // Map<String, String> payloadFromData = message.data as Map<String, String>;


    Map<String, String> payloadFromData =
    message.data.map((key, value) => MapEntry(key, value?.toString() ?? "NO DATA!"));
    print("HHHHH==> FROM: $from, My Payload From Data: $payloadFromData");

    await AwesomeNotifications().createNotification(
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

  _navigateToScreen(Map<String, String>? payload) {
    print("HHHHH==> payload: $payload");

    if (payload == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NavigationPage()),
      );
    } else {

      if (payload['screen'] == 'one') {
        //Navigator.of(context).pushNamed(ScreenOne.route);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScreenOne()),
        );
      } else {
        //Navigator.of(context).pushNamed(ScreenTwo.route);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScreenTwo()),
        );
      }
    }
  }
}
