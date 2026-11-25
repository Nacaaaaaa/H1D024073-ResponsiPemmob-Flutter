import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

enum SearchViewState { idle, loading, loaded, empty, error }

class SearchViewModel extends ChangeNotifier {
  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  SearchViewModel({
    WeatherApiService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? LocalStorageService();

  SearchViewState _state = SearchViewState.idle;
  List<LocationModel> _results = [];
  List<LocationModel> _history = [];
  String _lastQuery = '';
  String? _errorMessage;

  SearchViewState get state => _state;
  List<LocationModel> get results => List.unmodifiable(_results);
  List<LocationModel> get history => List.unmodifiable(_history);
  String get lastQuery => _lastQuery;
  String? get errorMessage => _errorMessage;

  Future<void> loadHistory() async {
    _history = await _storageService.getSearchHistory();
    notifyListeners();
  }

  Future<void> searchCity(String query) async {
    final trimmed = query.trim();
    _lastQuery = trimmed;

    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    _state = SearchViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final found = await _apiService.searchLocations(trimmed);
      _results = found;
      _state = found.isEmpty ? SearchViewState.empty : SearchViewState.loaded;
    } catch (e) {
      _results = [];
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = SearchViewState.error;
    }

    notifyListeners();
  }

  Future<void> addToHistory(LocationModel location) async {
    _history = await _storageService.addSearchHistory(location);
    notifyListeners();
  }

  Future<void> removeFromHistory(LocationModel location) async {
    _history = await _storageService.removeSearchHistory(location);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storageService.clearSearchHistory();
    _history = [];
    notifyListeners();
  }

  void clearSearch() {
    _results = [];
    _lastQuery = '';
    _errorMessage = null;
    _state = SearchViewState.idle;
    notifyListeners();
  }
}
