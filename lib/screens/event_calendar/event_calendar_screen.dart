import 'package:easy_wellness_biz_app/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class EventCalendarScreen extends StatelessWidget {
  static const String routeName = '/event_calendar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Body(),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
