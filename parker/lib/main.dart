import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/intro.dart';
import 'screens/sign_in.dart';
import 'screens/sign_up.dart';
import 'screens/user_home.dart';
import 'screens/admin_home.dart';
import 'screens/qr_scanner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp], // device rotation off
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Career Mentor',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF2F9F1),
      ),
      initialRoute: HomeApp.id, // first screen of app
      routes: {
        HomeApp.id: (context) => const HomeApp(),
        Intro.id: (context) => const Intro(),
        SignIn.id: (context) => const SignIn(),
        SignUp.id: (context) => const SignUp(),
        UserHome.id: (context) => const UserHome(),
        AdminHome.id: (context) => const AdminHome(),
        QrScanner.id: (context) => const QrScanner(),
      }, // all the screen and their object to set routes
    );
  }
}

class HomeApp extends StatelessWidget {
  // loading screen

  const HomeApp({Key? key}) : super(key: key);
  static String id = 'HomeApp';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return const Intro();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            // this will check for user is signed in or not
            FirebaseAuth.instance.authStateChanges().listen((User? user) {
              // Assign listener after the SDK is initialized successfully
              if (user == null) {
                // if user is signed out or it is new user
                // then redirect to intro screen
                Navigator.pushReplacementNamed(context, Intro.id);
              } else {
                // if user is signed in then redirect to userHome screen
                Navigator.pushReplacementNamed(context, UserHome.id);
              }
            });
          }
          return const Center(
            child: CircularProgressIndicator(), // loading animation
          );
        });
  }
}
