import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchVm = context.read<SearchViewModel>();
      searchVm.clearSearch();
      searchVm.loadHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    FocusScope.of(context).unfocus();
    context.read<SearchViewModel>().searchCity(_controller.text);
  }

  Future<void> _selectLocation(LocationModel location) async {
    final searchVm = context.read<SearchViewModel>();
    final weatherVm = context.read<WeatherViewModel>();

    await searchVm.addToHistory(location);
    await weatherVm.loadWeatherForLocation(location);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchVm = context.watch<SearchViewModel>();
    final weatherVm = context.watch<WeatherViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Lokasi'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // Input Pencarian Kota
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _triggerSearch(),
                      onChanged: (value) {
                        if (value.trim().isEmpty) {
                          context.read<SearchViewModel>().clearSearch();
                        }
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama kota (mis. Yogyakarta)',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  _controller.clear();
                                  context.read<SearchViewModel>().clearSearch();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _triggerSearch,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Cari'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Area Hasil Pencarian atau Daftar Favorit & Riwayat
              Expanded(
                child: _buildContent(context, searchVm, weatherVm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
  ) {
    switch (searchVm.state) {
      case SearchViewState.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Mencari lokasi...'),
            ],
          ),
        );

      case SearchViewState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                searchVm.errorMessage ?? 'Gagal melakukan pencarian lokasi.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _triggerSearch,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        );

      case SearchViewState.empty:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_rounded, size: 52),
              const SizedBox(height: 12),
              Text(
                'Kota "${searchVm.lastQuery}" tidak ditemukan.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Coba gunakan ejaan nama kota yang lebih spesifik.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blueGrey.shade600,
                    ),
              ),
            ],
          ),
        );

      case SearchViewState.loaded:
        return ListView.separated(
          itemCount: searchVm.results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final loc = searchVm.results[index];
            return _buildLocationCard(context, loc, weatherVm);
          },
        );

      case SearchViewState.idle:
        return _buildFavoritesAndHistory(context, searchVm, weatherVm);
    }
  }

  Widget _buildFavoritesAndHistory(
    BuildContext context,
    SearchViewModel searchVm,
    WeatherViewModel weatherVm,
  ) {
    final favorites = weatherVm.favorites;
    final history = searchVm.history;
    final textTheme = Theme.of(context).textTheme;

    if (favorites.isEmpty && history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.travel_explore_rounded,
              size: 60,
              color: Colors.blueGrey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'Cari nama kota untuk melihat cuaca',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Lokasi favorit dan riwayat pencarian Anda akan muncul di sini.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.blueGrey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (favorites.isNotEmpty) ...[
          Text('Lokasi Favorit', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          ...favorites.map(
            (loc) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildLocationCard(context, loc, weatherVm),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (history.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Riwayat Pencarian', style: textTheme.titleLarge),
              TextButton(
                onPressed: searchVm.clearHistory,
                child: const Text('Hapus Semua'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...history.map(
            (loc) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildLocationCard(
                context,
                loc,
                weatherVm,
                onDeleteHistory: () => searchVm.removeFromHistory(loc),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    LocationModel location,
    WeatherViewModel weatherVm, {
    VoidCallback? onDeleteHistory,
  }) {
    final isFav = weatherVm.isFavorite(location);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on_outlined),
        title: Text(
          location.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${location.subtitle.isNotEmpty ? '${location.subtitle} • ' : ''}'
          '(${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)})',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: isFav ? 'Hapus Favorit' : 'Simpan Favorit',
              icon: Icon(
                isFav ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFav ? const Color(0xFFF59E0B) : null,
              ),
              onPressed: () => weatherVm.toggleFavorite(location),
            ),
            if (onDeleteHistory != null)
              IconButton(
                tooltip: 'Hapus dari Riwayat',
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: onDeleteHistory,
              ),
          ],
        ),
        onTap: () => _selectLocation(location),
      ),
    );
  }
}
