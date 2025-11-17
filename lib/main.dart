import 'package:flutter/material.dart';
import 'package:Akatosh/screens/splash_screen.dart'; 
import 'package:Akatosh/screens/walkthrough_screen.dart';
import 'screens/login/signin_screen.dart'; 
import 'screens/login/signup_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../screens/Home/gemini_chat_screen.dart';

void main() {
  runApp(const MyApp());
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("8e7c0794-eccf-4b2f-a17d-e25ab2c7e73d");
  OneSignal.Notifications.requestPermission(false);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AKATOSH',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const SignInScreen(),
      debugShowCheckedModeBanner: false, 
      initialRoute: '/',
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(), 
      },
    );
  }
}

// You can create a separate screen for your main content
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: const Center(
        child: Text('Welcome to the Home Screen!'),
      ),
    );
  }
}
