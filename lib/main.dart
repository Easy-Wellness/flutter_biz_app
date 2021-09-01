import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/event_calendar_screen/event_calendar_screen.dart';
import 'screens/loading/loading_screen.dart';
import 'screens/login/login_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> initFirebaseSdk = Firebase.initializeApp();
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Easy Wellness',
      theme: theme(),
      home: FutureBuilder(
          future: initFirebaseSdk,
          builder: (_, snapshot) {
            if (snapshot.hasError) return Text('Cannot initialize Firebase');

            if (snapshot.connectionState == ConnectionState.done) {
              // Assign listener after the SDK is initialized successfully
              FirebaseAuth.instance.authStateChanges().listen((User? user) {
                if (user == null)
                  navigatorKey.currentState!
                      .pushReplacementNamed(LoginScreen.routeName);
                else
                  navigatorKey.currentState!
                      .pushReplacementNamed(EventCalendarScreen.routeName);
              });
            }
            return LoadingScreen();
          }),
      routes: routes,
    );
  }
}
