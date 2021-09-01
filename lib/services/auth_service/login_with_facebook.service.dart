import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

Future<UserCredential?> loginWithFacebook(BuildContext context) async {
  // by default we request the email and the public profile...
  final LoginResult result = await FacebookAuth.instance.login();
  final AccessToken? accessToken = result.accessToken;
  if (accessToken == null) return null;
  final facebookAuthCredential =
      FacebookAuthProvider.credential(accessToken.token);

  await FirebaseAuth.instance
      .signInWithCredential(facebookAuthCredential)
      // ignore: invalid_return_type_for_catch_error
      .catchError((err) => authExceptionHandler(err, context));
}

void authExceptionHandler(FirebaseAuthException err, BuildContext context) {
  if (err.code == 'account-exists-with-different-credential') {
    /// [credential]:AuthCredential (AuthCredential(providerId: facebook.com,
    /// signInMethod: facebook.com, token: 105553116412848))
    showDialog(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: Text(
              'The email address "${err.email}" associated with your Facebook account already exists'),
          content: Text(
              'A link has been sent to this email, please use this link to merge your Facebook account'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'I check my email right away',
                style: TextStyle(color: Colors.blue),
              ),
            )
          ],
        );
      },
    );
  }
}
