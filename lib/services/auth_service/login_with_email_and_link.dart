import 'package:firebase_auth/firebase_auth.dart';

Future<void> loginWithEmailAndLink(String email) {
  return FirebaseAuth.instance.sendSignInLinkToEmail(
    email: email,
    actionCodeSettings: ActionCodeSettings(
      /// Dynamic Links is "finaluniproject.page.link". U will need this value
      /// when you configure your iOS or Android app to detect the incoming
      /// app link, parse the underlying deep link and then complete the
      /// sign-in.
      handleCodeInApp: true,

      /// Redirect the user to this URL if the app is not installed on their
      /// device and the app was not able to be installed.
      url: 'https://gw-final-uni-project.web.app/emailSignin',
      iOSBundleId: 'com.sonxuannguyen.finaluniproject.easyWellness',

      /// Must specify the SHA-1 and SHA-256 of your Android app in the
      /// Firebase Console project settings.
      androidPackageName:
          'com.sonxuannguyen.finaluniproject.easy_wellness_biz_app',
    ),
  );
}
