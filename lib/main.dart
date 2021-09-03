import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notifiers/business_place_id_notifier.dart';
import 'routes.dart';
import 'screens/event_calendar/event_calendar_screen.dart';
import 'screens/loading/loading_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/set_place_id_app_state/set_place_id_app_state_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (_) => BusinessPlaceIdNotifier(),
    child: App(),
  ));
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
      title: 'Easy Wellness Biz',
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
                  Provider.of<BusinessPlaceIdNotifier>(context, listen: false)
                              .businessPlaceId ==
                          null
                      ? navigatorKey.currentState!.pushReplacementNamed(
                          SetPlaceIdAppStateScreen.routeName)
                      : navigatorKey.currentState!
                          .pushReplacementNamed(EventCalendarScreen.routeName);
              });
            }
            return LoadingScreen();
          }),
      routes: routes,
    );
  }
}
