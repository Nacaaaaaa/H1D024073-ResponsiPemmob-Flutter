import 'package:flutter/material.dart';

class WeatherInfo {
  final String description;
  final IconData icon;
  final Color color;

  const WeatherInfo({
    required this.description,
    required this.icon,
    required this.color,
  });
}

class WeatherCodeHelper {
  /// Mengonversi kode cuaca WMO dari Open-Meteo menjadi label Bahasa Indonesia & ikon.
  static WeatherInfo fromCode(int code) {
    switch (code) {
      case 0:
        return const WeatherInfo(
          description: 'Cerah',
          icon: Icons.wb_sunny_rounded,
          color: Color(0xFFF59E0B),
        );
      case 1:
        return const WeatherInfo(
          description: 'Sebagian Besar Cerah',
          icon: Icons.wb_sunny_outlined,
          color: Color(0xFFF59E0B),
        );
      case 2:
        return const WeatherInfo(
          description: 'Berawan Sebagian',
          icon: Icons.cloud_queue_rounded,
          color: Color(0xFF0EA5E9),
        );
      case 3:
        return const WeatherInfo(
          description: 'Mendung',
          icon: Icons.cloud_rounded,
          color: Color(0xFF64748B),
        );
      case 45:
      case 48:
        return const WeatherInfo(
          description: 'Berkabut',
          icon: Icons.foggy,
          color: Color(0xFF94A3B8),
        );
      case 51:
      case 53:
      case 55:
        return const WeatherInfo(
          description: 'Gerimis',
          icon: Icons.grain_rounded,
          color: Color(0xFF38BDF8),
        );
      case 56:
      case 57:
        return const WeatherInfo(
          description: 'Gerimis Beku',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF38BDF8),
        );
      case 61:
      case 63:
      case 65:
        return const WeatherInfo(
          description: 'Hujan',
          icon: Icons.water_drop_rounded,
          color: Color(0xFF2563EB),
        );
      case 66:
      case 67:
        return const WeatherInfo(
          description: 'Hujan Beku',
          icon: Icons.cloudy_snowing,
          color: Color(0xFF3B82F6),
        );
      case 71:
      case 73:
      case 75:
      case 77:
        return const WeatherInfo(
          description: 'Salju',
          icon: Icons.ac_unit_rounded,
          color: Color(0xFF60A5FA),
        );
      case 80:
      case 81:
      case 82:
        return const WeatherInfo(
          description: 'Hujan Deras',
          icon: Icons.umbrella_rounded,
          color: Color(0xFF1D4ED8),
        );
      case 85:
      case 86:
        return const WeatherInfo(
          description: 'Hujan Salju',
          icon: Icons.snowing,
          color: Color(0xFF60A5FA),
        );
      case 95:
      case 96:
      case 99:
        return const WeatherInfo(
          description: 'Badai Petir',
          icon: Icons.thunderstorm_rounded,
          color: Color(0xFF7C3AED),
        );
      default:
        return const WeatherInfo(
          description: 'Tidak Diketahui',
          icon: Icons.cloud_queue_rounded,
          color: Color(0xFF64748B),
        );
    }
  }

  /// Format string tanggal ISO (YYYY-MM-DD) menjadi format ringkas Bahasa Indonesia.
  static String formatDailyDate(String isoDate, int index) {
    if (index == 0) return 'Hari Ini';
    if (index == 1) return 'Besok';

    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;

    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final dayName = days[parsed.weekday - 1];
    final monthName = months[parsed.month - 1];
    return '$dayName, ${parsed.day} $monthName';
  }
}
