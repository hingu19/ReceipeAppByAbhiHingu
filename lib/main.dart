import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hungry/splash_screen.dart';
import 'package:hungry/util/colors.dart';
import 'package:hungry/views/screens/auth/welcome_page.dart';

// Future<void> main() async {
//   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//     systemNavigationBarColor: Colors.black,
//     systemNavigationBarIconBrightness: Brightness.light,
//   ));
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await GetStorage.init();
  await Firebase.initializeApp();
  // NetworkDioHttp.setDynamicHeader(endPoint: AppConstants.apiEndPoint);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: primaryWhite,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
      systemStatusBarContrastEnforced: true,
    ),
  );
  runApp( MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Open Sans',
        scaffoldBackgroundColor: Colors.white,
      ),
      // home: WelcomePage(),
      home: SplashScreen(),
    );
  }
}
