import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceSuggestion {
  final String displayName;
  final String? city;
  final String? state;
  final double? lat;
  final double? lng;

  const PlaceSuggestion({
    required this.displayName,
    this.city,
    this.state,
    this.lat,
    this.lng,
  });
}

abstract class PlacesService {
  Future<List<PlaceSuggestion>> search(String query);

  Future<PlaceSuggestion?> reverse({
    required double lat,
    required double lng,
  });
}

class NominatimPlacesService implements PlacesService {
  final http.Client _client;

  NominatimPlacesService({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<PlaceSuggestion>> search(String query) async {
    final q = query.trim();
    if (q.length < 3) return const [];

    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': q,
        'format': 'json',
        'addressdetails': '1',
        'limit': '5',
      },
    );

    final res = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'TransfortApp/1.0 (support@transfort.app)',
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Places search failed: HTTP ${res.statusCode}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) return const [];

    return decoded.map<PlaceSuggestion>((row) {
      final map = row is Map<String, dynamic> ? row : <String, dynamic>{};
      final address = map['address'] is Map<String, dynamic>
          ? (map['address'] as Map<String, dynamic>)
          : <String, dynamic>{};

      final displayName = (map['display_name'] as String?) ?? '';
      final city = (address['city'] as String?) ??
          (address['town'] as String?) ??
          (address['village'] as String?) ??
          (address['county'] as String?);
      final state = (address['state'] as String?);

      double? parseDouble(dynamic v) {
        if (v == null) return null;
        if (v is num) return v.toDouble();
        if (v is String) return double.tryParse(v);
        return null;
      }

      return PlaceSuggestion(
        displayName: displayName,
        city: city,
        state: state,
        lat: parseDouble(map['lat']),
        lng: parseDouble(map['lon']),
      );
    }).where((s) => s.displayName.isNotEmpty).toList(growable: false);
  }

  @override
  Future<PlaceSuggestion?> reverse({
    required double lat,
    required double lng,
  }) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      {
        'format': 'json',
        'addressdetails': '1',
        'lat': lat.toString(),
        'lon': lng.toString(),
      },
    );

    final res = await _client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'TransfortApp/1.0 (support@transfort.app)',
      },
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Places reverse failed: HTTP ${res.statusCode}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) return null;
    final address = decoded['address'] is Map<String, dynamic>
        ? (decoded['address'] as Map<String, dynamic>)
        : <String, dynamic>{};

    final displayName = (decoded['display_name'] as String?) ?? '';
    final city = (address['city'] as String?) ??
        (address['town'] as String?) ??
        (address['village'] as String?) ??
        (address['county'] as String?);
    final state = (address['state'] as String?);

    if (displayName.isEmpty) return null;

    return PlaceSuggestion(
      displayName: displayName,
      city: city,
      state: state,
      lat: lat,
      lng: lng,
    );
  }
}
