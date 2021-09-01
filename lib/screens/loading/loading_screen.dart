import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  static const String routeName = '/loading';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator.adaptive());
  }
}
