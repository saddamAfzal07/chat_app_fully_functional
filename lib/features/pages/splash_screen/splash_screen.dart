import 'package:chat_app/features/pages/auth/login_screen.dart';
import 'package:chat_app/features/pages/home_screen/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    setState(() {});
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      setState(() {});

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    });

    // if (FirebaseAuth.instance.currentUser != null) {
    //   print("user true");
    //   SchedulerBinding.instance.addPostFrameCallback((_) {
    //     Navigator.of(context).pushAndRemoveUntil(
    //         MaterialPageRoute(
    //           builder: (context) => HomePage(),
    //         ),
    //         (Route<dynamic> route) => false);
    //   });
    // } else {
    //   print("user false");
    //   Future.delayed(Duration(seconds: 2), () {
    //     setState(() {});
    //     SchedulerBinding.instance.addPostFrameCallback((_) {
    //       Navigator.of(context).pushReplacement(
    //         MaterialPageRoute(
    //           builder: (context) => LoginScreen(),
    //         ),
    //       );
    //     });
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(
        0xff3c83f1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            Image.asset("assets/images/chat.png"),
            Text(
              "Let,s\nChit Chat\nTogether",
              style: TextStyle(
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}
