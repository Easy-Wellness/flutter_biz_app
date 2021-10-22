import 'package:easy_wellness_biz_app/services/auth_service/login_with_email_and_link.dart';
import 'package:easy_wellness_biz_app/services/auth_service/login_with_facebook.service.dart';
import 'package:easy_wellness_biz_app/services/auth_service/login_with_google.service.dart';
import 'package:easy_wellness_biz_app/utils/check_if_email_is_valid.dart';
import 'package:easy_wellness_biz_app/utils/show_custom_snack_bar.dart';
import 'package:easy_wellness_biz_app/widgets/or_divider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_mail_app/open_mail_app.dart';

class LoginScreen extends StatelessWidget {
  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Body(),
      ),
    );
  }
}

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _emailInpController = TextEditingController();

  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _emailInpController.addListener(
      () => setState(() => _isEmpty = _emailInpController.text.isEmpty),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...[
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ThemeData()
                    .colorScheme
                    .copyWith(primary: Colors.blueGrey[700]!),
              ),
              child: TextField(
                controller: _emailInpController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Your email',
                  prefixIcon: const Icon(Icons.email),
                  suffixIcon: _isEmpty
                      ? null
                      : IconButton(
                          onPressed: () => _emailInpController.clear(),
                          icon: const Icon(Icons.clear),
                        ),
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.insert_link),
              style: ElevatedButton.styleFrom(primary: Colors.blueGrey[700]!),
              onPressed: _isEmpty
                  ? null
                  : () {
                      final email = _emailInpController.text;
                      final emailErr = checkIfEmailIsValid(email);
                      if (emailErr != null)
                        return showCustomSnackBar(context, emailErr);
                      loginWithEmailAndLink(email).catchError((e) {
                        print(e);
                        showCustomSnackBar(context, 'Sending email failed');
                      }).then((_) => showDialog(
                            context: context,
                            builder: (ctx) {
                              return CupertinoAlertDialog(
                                title: Text('An email has been sent to $email'),
                                content: const Text(
                                    'Please tap the link that we sent to your email to sign in.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      OpenMailApp.openMailApp();
                                    },
                                    child: Text(
                                      'Okay',
                                      style: TextStyle(
                                          color: Colors.blueGrey[700]!),
                                    ),
                                  )
                                ],
                              );
                            },
                          ));
                    },
              label: const Text('Sign in with email link'),
            ),
            OrDivider(),
            ElevatedButton.icon(
              onPressed: () => loginWithGoogle(),
              style: ElevatedButton.styleFrom(primary: Colors.white60),
              icon: SvgPicture.asset(
                'assets/icons/google_icon.svg',
                height: 24,
              ),
              label: Text(
                'Continue with Google',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => loginWithFacebook(context),
              style: ElevatedButton.styleFrom(primary: Colors.blue),
              icon: SvgPicture.asset(
                'assets/icons/facebook_icon.svg',
                height: 24,
                color: Colors.white,
              ),
              label: Text('Continue with Facebook'),
            ),
          ].expand(
            (widget) => [
              widget,
              const SizedBox(
                height: 8,
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailInpController.dispose();
    super.dispose();
  }
}
