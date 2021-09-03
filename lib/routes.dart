import 'package:flutter/material.dart';

import 'screens/error/error_screen.dart';
import 'screens/event_calendar/event_calendar_screen.dart';
import 'screens/loading/loading_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/set_place_id_app_state/set_place_id_app_state_screen.dart';
import 'screens/settings/settings_screen.dart';

enum RootScreen {
  eventCalendarScreen,
  settingsScreen,
}

final Map<String, WidgetBuilder> routes = {
  LoadingScreen.routeName: (_) => LoadingScreen(),
  LoginScreen.routeName: (_) => LoginScreen(),
  ErrorScreen.routeName: (_) => ErrorScreen(),

  /// Sub-screens of the root screen to select a global business place id
  SetPlaceIdAppStateScreen.routeName: (_) => SetPlaceIdAppStateScreen(),

  /// Sub-screens of the root Event Calendar Screen
  EventCalendarScreen.routeName: (_) => EventCalendarScreen(),

  /// Sub-screens of the root Event Calendar Screen
  SettingsScreen.routeName: (_) => SettingsScreen(),
};
