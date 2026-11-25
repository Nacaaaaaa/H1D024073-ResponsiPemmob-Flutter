class LocationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String admin1;
  final String timezone;

  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1 = '',
    this.timezone = 'auto',
  });

  String get subtitle {
    final parts = <String>[];
    if (admin1.isNotEmpty) parts.add(admin1);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  String get displayName =>
      subtitle.isNotEmpty ? '$name, $country' : name;

  factory LocationModel.fromGeocodingJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? 'Tidak diketahui',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: (json['country'] as String?) ?? '',
      admin1: (json['admin1'] as String?) ?? '',
      timezone: (json['timezone'] as String?) ?? 'auto',
    );
  }

  factory LocationModel.fromStorageJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: (json['country'] as String?) ?? '',
      admin1: (json['admin1'] as String?) ?? '',
      timezone: (json['timezone'] as String?) ?? 'auto',
    );
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'admin1': admin1,
      'timezone': timezone,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.name.toLowerCase() == name.toLowerCase() &&
        (other.latitude - latitude).abs() < 0.001 &&
        (other.longitude - longitude).abs() < 0.001;
  }

  @override
  int get hashCode =>
      Object.hash(name.toLowerCase(), latitude.toStringAsFixed(3), longitude.toStringAsFixed(3));
}
