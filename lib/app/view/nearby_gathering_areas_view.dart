import 'package:fi_toplan/app/models/gathering_area.dart';
import 'package:fi_toplan/app/services/gathering_area_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:developer' as developer;
import 'package:url_launcher/url_launcher.dart';

class NearbyGatheringAreasView extends StatefulWidget {
  const NearbyGatheringAreasView({super.key});

  @override
  State<NearbyGatheringAreasView> createState() =>
      _NearbyGatheringAreasViewState();
}

class _NearbyGatheringAreasViewState extends State<NearbyGatheringAreasView> {
  final GatheringAreaService _service = GatheringAreaService();
  bool _isLoading = true;
  String _errorMessage = '';
  List<GatheringArea> _nearbyAreas = [];
  Position? _currentPosition;
  final double _maxDistance = 500; // 500 metre yarıçap

  @override
  void initState() {
    super.initState();
    _loadNearbyAreas();
  }

  Future<void> _loadNearbyAreas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _nearbyAreas = [];
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

      // Tüm toplanma alanlarını getir
      final allAreas = await _service.fetchGatheringAreas();

      // 500 metre içindeki alanları filtrele
      final nearbyAreas = <GatheringArea>[];
      final distances = <double>[];

      for (final area in allAreas) {
        final areaCoordinates = _extractCoordinates(area);
        if (areaCoordinates != null) {
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            areaCoordinates.latitude,
            areaCoordinates.longitude,
          );

          if (distance <= _maxDistance) {
            nearbyAreas.add(area);
            distances.add(distance);
          }
        }
      }

      setState(() {
        _isLoading = false;
        _nearbyAreas = nearbyAreas;

        // Eğer hiç yakın alan bulunamadıysa hata mesajı göster
        if (nearbyAreas.isEmpty) {
          _errorMessage = '500 metre içinde toplanma alanı bulunamadı.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Bir hata oluştu: $e';
      });
    }
  }

  // GatheringArea'dan koordinat çıkarma yardımcı fonksiyonu
  LatLng? _extractCoordinates(GatheringArea area) {
    try {
      if (area.geometry.containsKey('coordinates')) {
        final coordinates = area.geometry['coordinates'];
        if (coordinates is List && coordinates.isNotEmpty) {
          final firstCoord = coordinates[0];
          if (firstCoord is List && firstCoord.isNotEmpty) {
            final secondCoord = firstCoord[0];
            if (secondCoord is List && secondCoord.isNotEmpty) {
              final thirdCoord = secondCoord[0];
              if (thirdCoord is List && thirdCoord.length >= 2) {
                final lon = thirdCoord[0];
                final lat = thirdCoord[1];
                if (lon is num && lat is num) {
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

  // Google Maps'te yol tarifi için URL açma
  Future<void> _openGoogleMapsDirections(LatLng destination) async {
    if (_currentPosition == null) return;

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&travelmode=driving',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Google Maps açılamadı')));
      }
    }
  }

  // Mesafe formatı
  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} metre uzaklıkta';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} km uzaklıkta';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('500m İçindeki Toplanma Alanları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyAreas,
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
                      const Icon(Icons.error_outline, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadNearbyAreas,
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
    if (_nearbyAreas.isEmpty || _currentPosition == null) {
      return const Center(child: Text('Yakında toplanma alanı bulunamadı.'));
    }

    return Column(
      children: [
        // Sayfanın üst kısmında kaç tane toplanma alanı bulunduğunu gösteren bilgi paneli
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              Text(
                '${_nearbyAreas.length} toplanma alanı bulundu',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Konumunuzdan 500 metre yarıçap içinde',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),

        // Harita
        SizedBox(
          height: 200,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              // Kullanıcının konumu için marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.my_location, size: 30),
                  ),
                ],
              ),
              // 500 metre yarıçaplı çember
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    radius: 500,
                    color: Colors.blue.withOpacity(0.2),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
              // Toplanma alanları için marker'lar
              MarkerLayer(
                markers:
                    _nearbyAreas
                        .map((area) {
                          final coords = _extractCoordinates(area);
                          if (coords == null) return null;

                          return Marker(
                            point: coords,
                            width: 30,
                            height: 30,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 24,
                            ),
                          );
                        })
                        .whereType<Marker>()
                        .toList(),
              ),
            ],
          ),
        ),

        // Toplanma alanları listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: _nearbyAreas.length,
            itemBuilder: (context, index) {
              final area = _nearbyAreas[index];
              final areaName =
                  area.properties['ad']?.toString() ?? 'İsimsiz Alan';
              final il = area.properties['il']?.toString() ?? '';
              final ilce = area.properties['ilce']?.toString() ?? '';
              final mahalle = area.properties['mahalle']?.toString() ?? '';

              // Mesafeyi hesapla
              final areaCoords = _extractCoordinates(area);
              String distance = 'Mesafe hesaplanamadı';

              if (areaCoords != null && _currentPosition != null) {
                final distanceMeters = Geolocator.distanceBetween(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  areaCoords.latitude,
                  areaCoords.longitude,
                );
                distance = _formatDistance(distanceMeters);
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    areaName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('$il, $ilce, $mahalle'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_walk,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            distance,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing:
                      areaCoords != null
                          ? IconButton(
                            icon: const Icon(
                              Icons.directions,
                              color: Colors.green,
                            ),
                            onPressed:
                                () => _openGoogleMapsDirections(areaCoords),
                            tooltip: 'Yol Tarifi Al',
                          )
                          : null,
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
