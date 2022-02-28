import 'package:example_awesome_notification/navigation_page.dart';
import 'package:example_awesome_notification/screen_one.dart';
import 'package:example_awesome_notification/screen_two.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.data}");
  AwesomeNotifications().createNotificationFromJsonData(message.data);
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  void initState() {
    super.initState();

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
    firebaseNotificationSettings();

  }

  firebaseNotificationSettings() {


    ///Gives you the message on which user taps and it opened the app from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        //final Map<String, dynamic> myData = message.data;
        //_firebaseMessagingBackgroundHandler(message);
        //notify2(message, "instance");
      }
    });

    ///Foreground work
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print(message.notification!.body ?? "");
        print(message.notification!.title ?? "");
        //_firebaseMessagingBackgroundHandler(message);
        notify2(message, "onMessage");
      }

    });

    ///Background  but app is open state: user taps on notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      //final String link = message.data['link'];
      //final Map<String, dynamic> myData = message.data;
      //_firebaseMessagingBackgroundHandler(message);
      notify2(message, "onMessageOpenedApp");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            notify();
          },
          child: const Icon(Icons.circle_notifications),
        ),
      ),
    );
  }

  void notify() async {

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
        ),
      //schedule: NotificationInterval(interval: 5, timeZone: timeZone, repeats: true),
    );
    AwesomeNotifications().actionStream.listen((receivedNotification) {
      Navigator.of(context).pushNamed(NavigationPage.route);
    });
  }


  void notify2(RemoteMessage message, String from) async {
    print("HHHHH ==> FROM: $from");
    String defaultImageLink = 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/Image_created_with_a_mobile_phone.png/2560px-Image_created_with_a_mobile_phone.png';
    // String timeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
    // print("HHHHH==> timeZone: $timeZone");
    //https://cdn.tutsplus.com/gamedev/uploads/legacy/043_freeShmupSprites/Free_Shmup_Sprites_Boss_Battle.jpg
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'my_test_not_id',
        title: message.notification?.title ?? "No Title",
        body: message.notification?.title ?? "No Body",
        bigPicture: message.data['link'] ?? defaultImageLink,
        notificationLayout: NotificationLayout.BigPicture,
      ),
      //schedule: NotificationInterval(interval: 5, timeZone: timeZone, repeats: true),
    );
    AwesomeNotifications().actionStream.listen((receivedNotification) {

      _navigateToScreen(message);

    });
  }

  _navigateToScreen(RemoteMessage message) {

    print("HHHHH==> screen in data: ${message.data['screen']}");

    if (message.data['screen'] == 'one') {
      Navigator.of(context).pushNamed(ScreenOne.route);
    } else {
      Navigator.of(context).pushNamed(ScreenTwo.route);
    }

  }
}
