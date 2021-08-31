import 'package:flutter/material.dart';

import 'login/login_screen.dart';

enum RootScreen {
  eventCalendarScreen,
}

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (_) => LoginScreen(),
};
