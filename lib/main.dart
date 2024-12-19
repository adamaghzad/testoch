import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'pages/login_page.dart';
import 'pages/home_page.dart'; // Import the home page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690), // Define the base design size (width x height)
      minTextAdapt: true,         // Automatically adjust text sizes
      splitScreenMode: true,      // Handle split-screen scenarios
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => LoginPage(),
            '/home': (context) => MyHomePage(),
          },
        );
      },
    );
  }
}
