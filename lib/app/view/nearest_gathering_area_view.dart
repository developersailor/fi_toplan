import 'package:fi_toplan/models/gathering_area.dart';
import 'package:fi_toplan/services/gathering_area_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:developer' as developer;
import 'package:url_launcher/url_launcher.dart';

class NearestGatheringAreaView extends StatefulWidget {
  const NearestGatheringAreaView({super.key});

  @override
  State<NearestGatheringAreaView> createState() =>
      _NearestGatheringAreaViewState();
}

class _NearestGatheringAreaViewState extends State<NearestGatheringAreaView> {
  final GatheringAreaService _service = GatheringAreaService();
  bool _isLoading = true;
  String _errorMessage = '';
  GatheringArea? _nearestArea;
  Position? _currentPosition;
  double _distance = 0;

  @override
  void initState() {
    super.initState();
    _loadNearestArea();
  }

  Future<void> _loadNearestArea() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Kullanıcı konumunu al
      final position = await _service.getCurrentLocation();
      if (position == null) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Konum alınamadı. Lütfen konum izinlerini kontrol edin.';
        });
        return;
      }

      _currentPosition = position;

      // En yakın toplanma alanını bul
      final nearestArea = await _service.findNearestGatheringArea(position);
      if (nearestArea == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Yakın toplanma alanı bulunamadı.';
        });
        return;
      }

      // Mesafeyi hesapla
      final areaCoordinates = _extractCoordinates(nearestArea);
      if (areaCoordinates != null) {
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          areaCoordinates.latitude,
          areaCoordinates.longitude,
        );
        _distance = distance;
      }

      setState(() {
        _isLoading = false;
        _nearestArea = nearestArea;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Bir hata oluştu: $e';
      });
    }
  }

  // Google Maps'te yol tarifi almak için URL oluşturup açan fonksiyon
  Future<void> _openGoogleMapsDirections(LatLng destination) async {
    if (_currentPosition == null) return;

    // Google Maps URL formatı: https://www.google.com/maps/dir/?api=1&origin=LAT,LNG&destination=LAT,LNG&travelmode=driving
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&travelmode=driving',
    );
    developer.log('Constructed URL: $url');
    // URL'yi aç
    if (await canLaunchUrl(url)) {
      developer.log('Can launch URL: $url');
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      developer.log('Cannot launch URL: $url');
      // URL açılamazsa hata göster
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Google Maps açılamadı')));
      }
    }
  }

  LatLng? _extractCoordinates(GatheringArea area) {
    try {
      if (area.geometry.containsKey('coordinates')) {
        final coordinates = area.geometry['coordinates'];
        // Koordinatları listeye dönüştürün
        if (coordinates is List && coordinates.isNotEmpty) {
          final firstCoord = coordinates[0];
          // İlk seviye koordinatları kontrol edin
          if (firstCoord is List && firstCoord.isNotEmpty) {
            final secondCoord = firstCoord[0];
            // İkinci seviye koordinatları kontrol edin
            if (secondCoord is List && secondCoord.isNotEmpty) {
              final thirdCoord = secondCoord[0];
              // Üçüncü seviye koordinatları kontrol edin
              if (thirdCoord is List && thirdCoord.length >= 2) {
                // Koordinat noktalarını kontrol edin
                final lon = thirdCoord[0];
                final lat = thirdCoord[1];

                if (lon is num && lat is num) {
                  // GeoJSON'da koordinatlar [longitude, latitude] şeklinde saklanır
                  // LatLng sınıfı ise [latitude, longitude] bekler, o yüzden çeviriyoruz
                  return LatLng(lat.toDouble(), lon.toDouble());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('En Yakın Toplanma Alanı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearestArea,
            tooltip: 'Yenile',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadNearestArea,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                ),
              )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_nearestArea == null || _currentPosition == null) {
      return const Center(child: Text('Veri bulunamadı.'));
    }

    final areaName =
        _nearestArea!.properties['ad']?.toString() ?? 'İsimsiz Alan';
    final il = _nearestArea!.properties['il']?.toString() ?? '';
    final ilce = _nearestArea!.properties['ilce']?.toString() ?? '';
    final mahalle = _nearestArea!.properties['mahalle']?.toString() ?? '';

    final areaCoordinates = _extractCoordinates(_nearestArea!);
    if (areaCoordinates == null) {
      return const Center(child: Text('Koordinat bilgisi bulunamadı.'));
    }

    return Column(
      children: [
        // Bilgileri gösteren kart
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          areaName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('$il, $ilce, $mahalle'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.directions_walk, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        _formatDistance(_distance),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Google Maps'te yol tarifi için buton ekliyoruz
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          () => _openGoogleMapsDirections(areaCoordinates),
                      icon: const Icon(Icons.directions),
                      label: const Text('Google Maps ile Yol Tarifi Al'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Harita
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: areaCoordinates,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  // Kullanıcının konumu
                  Marker(
                    point: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                  // Toplanma alanının konumu
                  Marker(
                    point: areaCoordinates,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      areaCoordinates,
                    ],
                    color: Colors.blue,
                    strokeWidth: 4,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} metre uzaklıkta';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} km uzaklıkta';
    }
  }
}
