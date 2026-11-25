import 'package:flutter/material.dart';

import '../../models/weather_model.dart';
import '../../utils/weather_code_helper.dart';

class DailyForecastTile extends StatelessWidget {
  final DailyForecast forecast;
  final int index;

  const DailyForecastTile({
    super.key,
    required this.forecast,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final info = WeatherCodeHelper.fromCode(forecast.weatherCode);
    final textTheme = Theme.of(context).textTheme;
    final dayLabel = WeatherCodeHelper.formatDailyDate(forecast.date, index);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dayLabel, style: textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  info.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.blueGrey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(info.icon, color: info.color, size: 26),
          const SizedBox(width: 12),
          SizedBox(
            width: 58,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  size: 14,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 2),
                Text(
                  '${forecast.precipitationProbabilityMax}%',
                  style: textTheme.labelMedium?.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 82,
            child: Text(
              '${forecast.temperature2mMax.round()}° / ${forecast.temperature2mMin.round()}°',
              textAlign: TextAlign.right,
              style: textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
