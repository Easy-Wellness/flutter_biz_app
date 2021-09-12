import 'package:easy_wellness_biz_app/utils/navigate_to_root_screen.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args =
        (ModalRoute.of(context)!.settings.arguments) as Map<String, dynamic>?;
    final currentIndex = (args?['rootScreenIndex'] ?? 0) as int;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[350]!)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.grey[750],
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: (index) =>
            navigateToRootScreen(context, RootScreen.values[index]),
        items: const [
          BottomNavigationBarItem(
            label: 'Calendar',
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note),
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
          )
        ],
      ),
    );
  }
}
