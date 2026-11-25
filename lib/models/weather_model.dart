class CurrentWeather {
  final String time;
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;

  const CurrentWeather({
    required this.time,
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      time: (json['time'] as String?) ?? '',
      temperature2m: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity2m: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed10m: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailyForecast {
  final String date;
  final int weatherCode;
  final double temperature2mMax;
  final double temperature2mMin;
  final int precipitationProbabilityMax;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationProbabilityMax,
  });
}

class WeatherResponse {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  const WeatherResponse({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.daily,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    final currentMap = json['current'] as Map<String, dynamic>? ?? {};
    final dailyMap = json['daily'] as Map<String, dynamic>? ?? {};

    final dates = (dailyMap['time'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final codes = (dailyMap['weather_code'] as List<dynamic>? ?? [])
        .map((e) => (e as num?)?.toInt() ?? 0)
        .toList();
    final maxTemps = (dailyMap['temperature_2m_max'] as List<dynamic>? ?? [])
        .map((e) => (e as num?)?.toDouble() ?? 0.0)
        .toList();
    final minTemps = (dailyMap['temperature_2m_min'] as List<dynamic>? ?? [])
        .map((e) => (e as num?)?.toDouble() ?? 0.0)
        .toList();
    final rainProbs =
        (dailyMap['precipitation_probability_max'] as List<dynamic>? ?? [])
            .map((e) => (e as num?)?.toInt() ?? 0)
            .toList();

    final count = dates.length;
    final dailyList = List<DailyForecast>.generate(count, (i) {
      return DailyForecast(
        date: dates[i],
        weatherCode: i < codes.length ? codes[i] : 0,
        temperature2mMax: i < maxTemps.length ? maxTemps[i] : 0.0,
        temperature2mMin: i < minTemps.length ? minTemps[i] : 0.0,
        precipitationProbabilityMax: i < rainProbs.length ? rainProbs[i] : 0,
      );
    });

    return WeatherResponse(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: (json['timezone'] as String?) ?? 'auto',
      current: CurrentWeather.fromJson(currentMap),
      daily: dailyList,
    );
  }
}
