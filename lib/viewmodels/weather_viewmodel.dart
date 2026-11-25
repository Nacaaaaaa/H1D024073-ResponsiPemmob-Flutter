import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';

enum WeatherViewState { initial, loading, loaded, empty, error }

class WeatherViewModel extends ChangeNotifier {
  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  WeatherViewModel({
    WeatherApiService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? LocalStorageService();

  static const LocationModel _defaultLocation = LocationModel(
    id: 1627896,
    name: 'Semarang',
    latitude: -6.9932,
    longitude: 110.4203,
    country: 'Indonesia',
    admin1: 'Jawa Tengah',
    timezone: 'Asia/Jakarta',
  );

  WeatherViewState _state = WeatherViewState.initial;
  LocationModel? _selectedLocation;
  WeatherResponse? _weather;
  String? _errorMessage;
  List<LocationModel> _favorites = [];

  WeatherViewState get state => _state;
  LocationModel? get selectedLocation => _selectedLocation;
  WeatherResponse? get weather => _weather;
  String? get errorMessage => _errorMessage;
  List<LocationModel> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(LocationModel location) {
    return _favorites.contains(location);
  }

  /// Memuat daftar favorit & lokasi terakhir tersimpan saat aplikasi dibuka.
  Future<void> initialize() async {
    _favorites = await _storageService.getFavorites();
    final lastLocation = await _storageService.getLastLocation();
    final initialTarget = lastLocation ??
        (_favorites.isNotEmpty ? _favorites.first : _defaultLocation);
    await loadWeatherForLocation(initialTarget);
  }

  /// Memuat data cuaca terbaru dari Open-Meteo API berdasarkan lokasi terpilih.
  Future<void> loadWeatherForLocation(LocationModel location) async {
    _selectedLocation = location;
    _state = WeatherViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _storageService.saveLastLocation(location);
      final response = await _apiService.fetchWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      if (response.daily.isEmpty) {
        _weather = null;
        _state = WeatherViewState.empty;
      } else {
        _weather = response;
        _state = WeatherViewState.loaded;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = WeatherViewState.error;
    }

    notifyListeners();
  }

  Future<void> refreshWeather() async {
    final target = _selectedLocation ?? _defaultLocation;
    await loadWeatherForLocation(target);
  }

  Future<void> toggleFavorite(LocationModel location) async {
    if (_favorites.contains(location)) {
      _favorites.removeWhere((item) => item == location);
    } else {
      _favorites.insert(0, location);
    }
    await _storageService.saveFavorites(_favorites);
    notifyListeners();
  }
}
