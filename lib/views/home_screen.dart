import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../utils/weather_code_helper.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/daily_forecast_tile.dart';
import 'widgets/weather_metric_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().initialize();
    });
  }

  Future<void> _openSearchScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherViewModel>(
      builder: (context, vm, _) {
        final selected = vm.selectedLocation;
        final isFav = selected != null && vm.isFavorite(selected);

        return Scaffold(
          appBar: AppBar(
            title: Text(selected?.name ?? 'Cuaca'),
            actions: [
              if (selected != null)
                IconButton(
                  tooltip: isFav ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
                  icon: Icon(
                    isFav ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isFav ? const Color(0xFFF59E0B) : null,
                  ),
                  onPressed: () {
                    vm.toggleFavorite(selected);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFav
                              ? '${selected.name} dihapus dari favorit'
                              : '${selected.name} disimpan ke favorit',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              IconButton(
                tooltip: 'Cari Kota',
                icon: const Icon(Icons.search_rounded),
                onPressed: _openSearchScreen,
              ),
            ],
          ),
          body: SafeArea(
            child: _buildBody(context, vm),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
    switch (vm.state) {
      case WeatherViewState.initial:
      case WeatherViewState.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat data cuaca terbaru...'),
            ],
          ),
        );

      case WeatherViewState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal Memuat Cuaca',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  vm.errorMessage ?? 'Terjadi kesalahan saat menghubungi server.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blueGrey.shade700,
                      ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: vm.refreshWeather,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        );

      case WeatherViewState.empty:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_searching_rounded, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Data cuaca belum tersedia',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _openSearchScreen,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Cari Lokasi'),
                ),
              ],
            ),
          ),
        );

      case WeatherViewState.loaded:
        final weather = vm.weather!;
        final location = vm.selectedLocation!;
        return _buildLoadedContent(context, location, weather, vm);
    }
  }

  Widget _buildLoadedContent(
    BuildContext context,
    LocationModel location,
    WeatherResponse weather,
    WeatherViewModel vm,
  ) {
    final current = weather.current;
    final todayForecast = weather.daily.isNotEmpty ? weather.daily.first : null;
    final weatherInfo = WeatherCodeHelper.fromCode(current.weatherCode);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: vm.refreshWeather,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          final gridColumns = isWide ? 3 : 2;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kartu Cuaca Utama (Hero Card)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withValues(alpha: 0.82),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              location.subtitle.isNotEmpty
                                  ? '${location.name}, ${location.subtitle}'
                                  : location.name,
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${current.temperature2m.toStringAsFixed(1)}°C',
                                  style: textTheme.displayLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  weatherInfo.description,
                                  style: textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Terasa seperti ${current.apparentTemperature.toStringAsFixed(1)}°C',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            weatherInfo.icon,
                            size: 72,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      if (todayForecast != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Maks ${todayForecast.temperature2mMax.round()}°C  •  Min ${todayForecast.temperature2mMin.round()}°C  •  Zona ${weather.timezone}',
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Text('Detail Cuaca Saat Ini', style: textTheme.titleLarge),
                const SizedBox(height: 10),

                // Grid Informasi Tambahan (Responsif)
                GridView.count(
                  crossAxisCount: gridColumns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: isWide ? 2.0 : 1.55,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    WeatherMetricCard(
                      icon: Icons.water_drop_rounded,
                      label: 'Kelembapan',
                      value: '${current.relativeHumidity2m}%',
                      iconColor: const Color(0xFF0EA5E9),
                    ),
                    WeatherMetricCard(
                      icon: Icons.air_rounded,
                      label: 'Kecepatan Angin',
                      value: '${current.windSpeed10m.toStringAsFixed(1)} km/j',
                      iconColor: const Color(0xFF0284C7),
                    ),
                    WeatherMetricCard(
                      icon: Icons.umbrella_rounded,
                      label: 'Peluang Hujan',
                      value:
                          '${todayForecast?.precipitationProbabilityMax ?? 0}%',
                      iconColor: const Color(0xFF2563EB),
                    ),
                    WeatherMetricCard(
                      icon: Icons.grain_rounded,
                      label: 'Curah Hujan',
                      value: '${current.precipitation.toStringAsFixed(1)} mm',
                      iconColor: const Color(0xFF4F46E5),
                    ),
                    WeatherMetricCard(
                      icon: Icons.thermostat_rounded,
                      label: 'Suhu Dirasakan',
                      value:
                          '${current.apparentTemperature.toStringAsFixed(1)}°C',
                      iconColor: const Color(0xFFEA580C),
                    ),
                    WeatherMetricCard(
                      icon: Icons.code_rounded,
                      label: 'Kode Cuaca WMO',
                      value: '${current.weatherCode}',
                      iconColor: const Color(0xFF64748B),
                    ),
                  ],
                ),

                const SizedBox(height: 22),
                Text(
                  'Perkiraan ${weather.daily.length} Hari Ke Depan',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 10),

                // Daftar Perkiraan Cuaca Harian
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: weather.daily.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Colors.blueGrey.withValues(alpha: 0.12),
                    ),
                    itemBuilder: (context, index) {
                      return DailyForecastTile(
                        forecast: weather.daily[index],
                        index: index,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
