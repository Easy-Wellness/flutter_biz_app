import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_wellness_biz_app/utils/show_custom_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _initDynamicLinks() async {
    /// Listeners for link callbacks when the application is active or in
    /// background...
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData? dynamicLink) async {
        final deepLink = dynamicLink?.link;
        if (deepLink != null)
          _verifyEmailLinkAndSignIn(
              navigatorKey.currentContext!, deepLink.toString());
      },
      onError: (OnLinkErrorException e) async {
        print('onLinkError');
        print(e.message);
      },
    );

    /// If your app did not open from a dynamic link, getInitialLink() will
    /// return null.
    final data = await FirebaseDynamicLinks.instance.getInitialLink();
    final deepLink = data?.link;
    if (deepLink != null)
      _verifyEmailLinkAndSignIn(
          navigatorKey.currentContext!, deepLink.toString());
  }

  @override
  void initState() {
    /// This is only called once after the widget is mounted.
    WidgetsBinding.instance!.addPostFrameCallback(
      (_) {
        this._initDynamicLinks();

        /// Assign listener after the SDK is initialized successfully.
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
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
        });
      },
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

Future<User?> _verifyEmailLinkAndSignIn(
  BuildContext context,
  String authLinkSentToEmail,
) async {
  final auth = FirebaseAuth.instance;
  if (!auth.isSignInWithEmailLink(authLinkSentToEmail)) return null;

  /// Retrieve the email from wherever you stored it.
  final prefs = await SharedPreferences.getInstance();
  final emailToAuthViaLink = prefs.getString('emailToAuthViaLink');
  if (emailToAuthViaLink == null) return null;

  try {
    // The client SDK will parse the code from the link for you.
    final identityInfo = await auth.signInWithEmailLink(
        email: emailToAuthViaLink, emailLink: authLinkSentToEmail);
    print('Successfully signed in with email link!');
    // Additional user profile info *not* available via:
    // identityInfo.additionalUserInfo.profile == null
    // You can check if the user is new or existing:
    // identityInfo.additionalUserInfo.isNewUser;
    return identityInfo.user;
  } catch (onError) {
    String extraMsg = '';
    final error = onError as FirebaseAuthException;
    if (error.code == 'invalid-action-code')
      extraMsg = '. The link is incorrect, expired, or has already been used.';
    showCustomSnackBar(context, 'Error signing in with email link$extraMsg');
  }
}
