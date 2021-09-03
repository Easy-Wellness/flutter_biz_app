import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'business_place_id';

class BusinessPlaceIdNotifier with ChangeNotifier {
  String? _currentPlaceId;

  BusinessPlaceIdNotifier() {
    _loadPlaceIdFromDisk();
  }

  Future<void> _loadPlaceIdFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    _currentPlaceId = prefs.getString(_prefKey);

    /// No root screen is mounted when [_currentPlaceId] is null
    if (_currentPlaceId != null) notifyListeners();
  }

  Future<void> _persistPlaceIdToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_prefKey, _currentPlaceId!);
  }

  String? get businessPlaceId => _currentPlaceId;

  set newBusinessPlaceId(String newPlaceId) {
    if (newPlaceId == _currentPlaceId) return;
    _currentPlaceId = newPlaceId;
    notifyListeners();
    _persistPlaceIdToDisk();
  }
}
