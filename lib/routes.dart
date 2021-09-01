import 'package:flutter/material.dart';

import 'screens/error/error_screen.dart';
import 'screens/event_calendar/event_calendar_screen.dart';
import 'screens/loading/loading_screen.dart';
import 'screens/login/login_screen.dart';

enum RootScreen {
  eventCalendarScreen,
}

final Map<String, WidgetBuilder> routes = {
  LoadingScreen.routeName: (_) => LoadingScreen(),
  LoginScreen.routeName: (_) => LoginScreen(),
  ErrorScreen.routeName: (_) => ErrorScreen(),

  /// Sub-screens of the root Event Calendar Screen
  EventCalendarScreen.routeName: (_) => EventCalendarScreen(),
};
