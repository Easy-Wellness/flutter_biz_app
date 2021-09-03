import 'package:flutter/material.dart';

class SetPlaceIdAppStateScreen extends StatelessWidget {
  static const String routeName = '/set_place_id_app_state';

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
    return Center(child: Text('This screen allows u to set a global place id'));
  }
}
