import 'package:flutter/material.dart';
// Removed: import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'pages/login_page.dart';
import 'pages/home_page copy.dart'; // Ensure this path is correct

// Removed: import 'utils/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Removed: Initialize Notification Service
  // await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Keep this if you use it elsewhere
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => MyHomePage1(),
      },
      // If you removed ScreenUtilInit and no longer need it, ensure no related code remains.
    );
  }
}
