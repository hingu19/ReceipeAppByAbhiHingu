import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hungry/views/screens/auth/welcome_page.dart';
import 'package:hungry/views/screens/home_page.dart';

import 'controller/authController.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Color backgroundColor = Colors.white; // Replace with your desired background colors.dart
  var controller = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      startTime();
    });
  }

  startTime() async {
    return Timer(
       Duration(milliseconds: 1500),
          () async {
        // Replace 'LoginScreen' with your actual login screen

            var isLogin = await controller.isUserSignedIn();
            if (isLogin) {
              Get.offAll(() =>  HomePage());
            } else {
              Get.offAll(() =>  WelcomePage());

            }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/Indian.png', // Replace with your actual logo path
      height: Get.height,
      width:Get.width ,
      fit: BoxFit.cover,
    );
  }
}

// Placeholder for LoginScreen, replace it with your actual LoginScreen class
class PlaceholderLoginScreen extends StatelessWidget {
  const PlaceholderLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('welcome page'),
      ),
      body: Center(
        child: Text(''),
      ),
    );
  }
}
