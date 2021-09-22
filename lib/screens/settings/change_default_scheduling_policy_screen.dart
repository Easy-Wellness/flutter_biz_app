import 'package:flutter/material.dart';

class ChangeDefaultSchedulingPolicyScreen extends StatelessWidget {
  const ChangeDefaultSchedulingPolicyScreen({Key? key}) : super(key: key);

  static const String routeName = '/change_default_scheduling_policy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduling policy'),
      ),
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
