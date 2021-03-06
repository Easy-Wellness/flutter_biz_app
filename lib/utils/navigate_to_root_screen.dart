import 'package:easy_wellness_biz_app/screens/chat_room_list/chat_room_list_screen.dart';
import 'package:easy_wellness_biz_app/screens/event_calendar/event_calendar_screen.dart';
import 'package:easy_wellness_biz_app/screens/service_list/service_list_screen.dart';
import 'package:easy_wellness_biz_app/screens/set_place_id_app_state/set_place_id_app_state_screen.dart';
import 'package:easy_wellness_biz_app/screens/setting_list/setting_list_screen.dart';
import 'package:flutter/material.dart';

enum RootScreen {
  eventCalendarScreen,
  serviceListScreen,
  chatRoomListScreen,
  settingListScreen,
  // The screen below must be at the last index
  setPlaceIdAppStateScreen,
}

void navigateToRootScreen(BuildContext context, RootScreen screen) {
  /// Keep disposing screens until meeting the first screen
  Navigator.of(context).popUntil((route) => route.isFirst);
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      /// Tells the [CustomBottomNavBar] of the new screen the index of
      /// the root screen we'tr trying to navigate to
      settings: RouteSettings(arguments: {'rootScreenIndex': screen.index}),
      pageBuilder: (_, __, ___) => _getRootScreenWidget(screen),
      transitionDuration: const Duration(milliseconds: 100),

      ///  After navigating from route A to route B, the widgets in
      /// route B will fade in (go from opacity 0 to 1) gradually
      transitionsBuilder: (_, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

Widget _getRootScreenWidget(RootScreen rootScreen) {
  switch (rootScreen) {
    case RootScreen.eventCalendarScreen:
      return EventCalendarScreen();
    case RootScreen.serviceListScreen:
      return ServiceListScreen();
    case RootScreen.chatRoomListScreen:
      return ChatRoomListScreen();
    case RootScreen.settingListScreen:
      return SettingListScreen();
    case RootScreen.setPlaceIdAppStateScreen:
      return SetPlaceIdAppStateScreen();
  }
}
