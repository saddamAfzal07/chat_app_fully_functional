import 'dart:developer';

import 'package:chat_app/features/pages/auth/login_screen.dart';
import 'package:chat_app/features/pages/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';

late Size mq;
void main() async {
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then(
  //   (value) {},
  // );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // navigation bar color
    statusBarColor: Colors.white, // status bar color
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var result = await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');
  log('\nNotification Channel Result: $result');
  runApp(const MyApp());
  // configLoading();
}

// void configLoading() {
//   EasyLoading.instance
//     ..displayDuration = const Duration(milliseconds: 2000)
//     ..indicatorType = EasyLoadingIndicatorType.fadingCircle
//     ..loadingStyle = EasyLoadingStyle.dark
//     ..indicatorSize = 45.0
//     ..radius = 10.0
//     ..progressColor = Colors.yellow
//     ..backgroundColor = Colors.green
//     ..indicatorColor = Colors.yellow
//     ..textColor = Colors.yellow
//     ..maskColor = Colors.blue.withOpacity(0.5)
//     ..userInteractions = true
//     ..dismissOnTap = false;
//   // ..customAnimation = CustomAnimation();
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18.0,
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
      // builder: EasyLoading.init(),
    );
  }
}
