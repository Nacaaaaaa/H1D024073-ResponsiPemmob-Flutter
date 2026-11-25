import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';

class LocalStorageService {
  static const String _favoritesKey = 'favorite_locations';
  static const String _historyKey = 'search_history';
  static const String _lastLocationKey = 'last_selected_location';
  static const int _maxHistoryItems = 10;

  Future<List<LocationModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_favoritesKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => LocationModel.fromStorageJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(favorites.map((loc) => loc.toStorageJson()).toList());
    await prefs.setString(_favoritesKey, encoded);
  }

  Future<List<LocationModel>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => LocationModel.fromStorageJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LocationModel>> addSearchHistory(LocationModel location) async {
    final current = await getSearchHistory();
    current.removeWhere((item) => item == location);
    current.insert(0, location);
    if (current.length > _maxHistoryItems) {
      current.removeRange(_maxHistoryItems, current.length);
    }
    await _saveHistory(current);
    return current;
  }

  Future<List<LocationModel>> removeSearchHistory(LocationModel location) async {
    final current = await getSearchHistory();
    current.removeWhere((item) => item == location);
    await _saveHistory(current);
    return current;
  }

  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> _saveHistory(List<LocationModel> history) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(history.map((loc) => loc.toStorageJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }

  Future<LocationModel?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastLocationKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return LocationModel.fromStorageJson(decoded);
  }

  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey, jsonEncode(location.toStorageJson()));
  }
}
