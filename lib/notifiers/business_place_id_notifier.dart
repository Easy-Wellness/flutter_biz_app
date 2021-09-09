import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefKey = 'business_place_id';

class BusinessPlaceIdNotifier with ChangeNotifier {
  String? _currentPlaceId;

  /// Because the constructor cannot be marked as [async] to [await] pending
  /// operation, we block it forever. The consumers of this notifier use
  /// the init() [async] function instead.
  factory BusinessPlaceIdNotifier() => BusinessPlaceIdNotifier._internal();

  BusinessPlaceIdNotifier._internal();

  Future<BusinessPlaceIdNotifier> init() async {
    await _loadPlaceIdFromDisk();
    return this;
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

  Future<void> _removePlaceIdFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_prefKey);
  }

  String? get businessPlaceId => _currentPlaceId;

  set businessPlaceId(String? newPlaceId) {
    if (newPlaceId == _currentPlaceId) return;
    _currentPlaceId = newPlaceId;
    notifyListeners();
    (newPlaceId == null) ? _removePlaceIdFromDisk() : _persistPlaceIdToDisk();
  }
}
