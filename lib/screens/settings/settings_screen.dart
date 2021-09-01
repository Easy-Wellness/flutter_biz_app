import 'package:easy_wellness_biz_app/widgets/custom_bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Body(),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: TextButtonTheme(
        data: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: Colors.black87,
            alignment: Alignment.centerLeft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Divider(indent: 10, endIndent: 10, thickness: 1),
            TextButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: Icon(Icons.logout_outlined),
              label: Text('Sign Out'),
              style:
                  TextButton.styleFrom(primary: Theme.of(context).errorColor),
            ),
          ],
        ),
      ),
    );
  }
}
