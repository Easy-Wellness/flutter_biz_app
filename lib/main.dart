import 'package:easy_wellness_biz_app/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'login/login_screen.dart';
import 'routes.dart';

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
                  print('Logged-in successfully');
                //   navigatorKey.currentState!
                //       .pushReplacementNamed(ExploreScreen.routeName);
              });
            }

            return const Center(child: CircularProgressIndicator.adaptive());
          }),
      routes: routes,
    );
  }
}
