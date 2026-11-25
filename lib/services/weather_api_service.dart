import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';

class WeatherApiService {
  static const String _forecastBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil data cuaca terkini & perkiraan harian dari Open-Meteo Forecast API (GET).
  Future<WeatherResponse> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_forecastBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'timezone': 'auto',
      },
    );

    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        debugPrint('GET URL: $uri');
        debugPrint('API RESPONSE: ${response.body}');
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherResponse.fromJson(decoded);
      } else {
        throw Exception(
          'Gagal mengambil data cuaca (HTTP ${response.statusCode}).',
        );
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on TimeoutException {
      throw Exception('Permintaan ke server cuaca melebihi batas waktu.');
    } on FormatException {
      throw Exception('Format data respons dari server cuaca tidak valid.');
    }
  }

  /// Mencari lokasi kota berdasarkan nama menggunakan Open-Meteo Geocoding API (GET).
  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.parse(_geocodingBaseUrl).replace(
      queryParameters: {
        'name': trimmed,
        'count': '10',
        'language': 'id',
        'format': 'json',
      },
    );

    try {
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        debugPrint('GET URL: $uri');
        debugPrint('API RESPONSE: ${response.body}');
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final results = decoded['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) {
          return [];
        }
        return results
            .map((item) =>
                LocationModel.fromGeocodingJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Gagal mencari lokasi (HTTP ${response.statusCode}).',
        );
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on TimeoutException {
      throw Exception('Pencarian lokasi melebihi batas waktu.');
    } on FormatException {
      throw Exception('Format data hasil pencarian tidak valid.');
    }
  }
}
