import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fi_toplan/models/gathering_area.dart';
import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GatheringAreaService {
  Future<List<GatheringArea>> fetchGatheringAreas() async {
    try {
      final response =
          await rootBundle.loadString('assets/toplanma_alanlari.json');
      final data = json.decode(response) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>;

      var areas = <GatheringArea>[];

      for (var i = 0; i < features.length; i++) {
        try {
          final feature = features[i] as Map<String, dynamic>;

          // Null kontrolü ve debugging için özellikleri kontrol edelim
          developer.log('Processing feature $i: ${feature['id']}');
          if (feature['id'] == null) developer.log('id is null');
          if (feature['geometryName'] == null) {
            developer.log('geometryName is null');
          }
          if (feature['geometry'] == null) developer.log('geometry is null');
          if (feature['properties'] == null) {
            developer.log('properties is null');
          }

          final area = GatheringArea.fromJson(feature);
          areas.add(area);
        } catch (e) {
          developer.log('Error processing feature at index $i: $e');
          // Hatalı verileri atla ama listenin geri kalanını işlemeye devam et
          continue;
        }
      }

      return areas;
    } catch (e) {
      developer.log('Error fetching gathering areas: $e');
      rethrow;
    }
  }

  // Kullanıcının konumuna göre en yakın toplanma alanını bulan fonksiyon
  Future<GatheringArea?> findNearestGatheringArea(Position userPosition) async {
    try {
      final areas = await fetchGatheringAreas();
      if (areas.isEmpty) return null;

      GatheringArea? nearestArea;
      var nearestDistance = double.infinity;

      // Her bir toplanma alanını kontrol et
      for (final area in areas) {
        // JSON'daki MultiPolygon koordinatlarından merkez noktayı hesaplayalım
        final coordinates = _getAreaCoordinates(area);
        if (coordinates == null) continue;

        // Kullanıcı konumuyla toplanma alanı arasındaki mesafeyi hesapla
        final distance = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          coordinates.latitude,
          coordinates.longitude,
        );

        // Daha yakın bir alan bulunduysa güncelle
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestArea = area;
        }
      }

      return nearestArea;
    } catch (e) {
      developer.log('Error finding nearest gathering area: $e');
      return null;
    }
  }

  // Toplanma alanının merkez koordinatlarını hesaplar
  LatLng? _getAreaCoordinates(GatheringArea area) {
    try {
      if (area.geometry.containsKey('coordinates')) {
        final coordinates = area.geometry['coordinates'];
        if (coordinates is List && coordinates.isNotEmpty) {
          if (coordinates[0] is List<dynamic> &&
              (coordinates[0] as List<dynamic>).isNotEmpty) {
            if (coordinates[0][0] is List &&
                coordinates[0][0] != null &&
                (coordinates[0][0] as List).isNotEmpty) {
              // MultiPolygon tipindeki koordinatlarda ilk noktayı alalım
              // Daha gelişmiş bir sistemde polygon'un merkezini hesaplayabiliriz
              if (coordinates[0][0][0] != null &&
                  coordinates[0][0][0] is List &&
                  (coordinates[0][0][0] as List).length >= 2) {
                final point = coordinates[0][0][0];
                if (point[0] is num && point[1] is num) {
                  // GeoJSON'da koordinatlar [longitude, latitude] şeklinde saklanır
                  // LatLng sınıfı ise [latitude, longitude] bekler, o yüzden çeviriyoruz
                  return LatLng(point[1] as double, point[0] as double);
                }
              }
            }
          }
        }
      }
      return null;
    } catch (e) {
      developer.log('Error extracting coordinates: $e');
      return null;
    }
  }

  // Konum izni alıp kullanıcının güncel konumunu döndüren yardımcı fonksiyon
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum servisi açık mı kontrol et
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      developer.log('Location services are disabled.');
      return null;
    }

    // Konum izni kontrol et
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        developer.log('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      developer.log('Location permissions are permanently denied');
      return null;
    }

    // Konum al
    return Geolocator.getCurrentPosition();
  }
}
