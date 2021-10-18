import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notifiers/business_place_id_notifier.dart';
import 'routes.dart';
import 'screens/login/login_screen.dart';
import 'screens/set_place_id_app_state/set_place_id_app_state_screen.dart';
import 'screens/setting_list/setting_list_screen.dart';
import 'theme.dart';
import 'utils/navigate_to_root_screen.dart';

const _useFirebaseEmulatorSuite = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp()
      // ignore: invalid_return_type_for_catch_error
      .catchError((_) => print('Cannot initialize Firebase'));

  if (_useFirebaseEmulatorSuite) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

    /// See https://firebase.flutter.dev/docs/firestore/usage#emulator-usage
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  final businessPlaceIdNotifier = await BusinessPlaceIdNotifier().init();
  runApp(ChangeNotifierProvider(
    create: (_) => businessPlaceIdNotifier,
    child: App(),
  ));
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    /// This is only called once after the widget is mounted.
    WidgetsBinding.instance!.addPostFrameCallback(
      /// Assign listener after the SDK is initialized successfully.
      (_) => FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null)
          navigatorKey.currentState!
              .pushReplacementNamed(LoginScreen.routeName);
        else
          Provider.of<BusinessPlaceIdNotifier>(context, listen: false)
                      .businessPlaceId ==
                  null
              ? navigatorKey.currentState!
                  .pushReplacementNamed(SetPlaceIdAppStateScreen.routeName)
              : navigatorKey.currentState!.pushReplacementNamed(
                  SettingListScreen.routeName,
                  arguments: {
                    'rootScreenIndex': RootScreen.settingListScreen.index
                  },
                );
      }),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'Easy Wellness Biz',
      home: LoginScreen(),
      theme: theme(),
      routes: routes,
    );
  }
}
