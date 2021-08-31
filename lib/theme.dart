import 'package:flutter/material.dart';

ThemeData theme() {
  return ThemeData(
    primarySwatch: Colors.green, // MaterialColor, different shades of a color
    primaryColor: Colors.black, // one of the shades in the primarySwatch
    appBarTheme: _appBarTheme(),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}

AppBarTheme _appBarTheme() {
  return AppBarTheme(
    backwardsCompatibility: false,
    color: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    foregroundColor: Colors.black,
  );
}
