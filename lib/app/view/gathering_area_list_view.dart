import 'package:fi_toplan/app/view/nearest_gathering_area_view.dart';
import 'package:fi_toplan/app/view/nearby_gathering_areas_view.dart';
import 'package:fi_toplan/models/gathering_area.dart';
import 'package:fi_toplan/services/gathering_area_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GatheringAreaListView extends StatefulWidget {
  const GatheringAreaListView({super.key});

  @override
  _GatheringAreaListViewState createState() => _GatheringAreaListViewState();
}

class _GatheringAreaListViewState extends State<GatheringAreaListView> {
  late Future<List<GatheringArea>> futureGatheringAreas;
  final GatheringAreaService _service = GatheringAreaService();

  @override
  void initState() {
    super.initState();
    futureGatheringAreas = _service.fetchGatheringAreas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toplanma Alanları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: GatheringAreaSearchDelegate(futureGatheringAreas),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<GatheringArea>>(
        future: futureGatheringAreas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Toplanma alanı bulunamadı'));
          }

          final gatheringAreas = snapshot.data!;
          return Column(
            children: [
              // Konum temelli navigasyon butonları
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // En yakın toplanma alanı butonu
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<NearestGatheringAreaView>(
                            builder:
                                (context) => const NearestGatheringAreaView(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.near_me),
                      label: const Text('En Yakın Toplanma Alanını Bul'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 500 metre içindeki toplanma alanları butonu
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<NearbyGatheringAreasView>(
                            builder:
                                (context) => const NearbyGatheringAreasView(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.radar),
                      label: const Text('500m İçindeki Toplanma Alanları'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),

              // Alanlar listesi başlığı
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.list_alt, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Tüm Toplanma Alanları',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Alanlar listesi
              Expanded(
                child: ListView.builder(
                  itemCount: gatheringAreas.length,
                  itemBuilder: (context, index) {
                    final area = gatheringAreas[index];
                    // Use null-safe approach for accessing properties
                    final areaName =
                        area.properties['ad']?.toString() ?? 'İsimsiz Alan';
                    final il = area.properties['il']?.toString() ?? '';
                    final ilce = area.properties['ilce']?.toString() ?? '';
                    final mahalle =
                        area.properties['mahalle']?.toString() ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          areaName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('$il, $ilce, $mahalle'),
                        trailing: const Icon(Icons.map_outlined),
                        onTap: () {
                          _showMapBottomSheet(context, gatheringAreas, index);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMapBottomSheet(
    BuildContext context,
    List<GatheringArea> areas,
    int initialAreaIndex,
  ) {
    final area = areas[initialAreaIndex];
    final areaName = area.properties['ad']?.toString() ?? 'İsimsiz Alan';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // Makes the bottom sheet full screen

      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9, // Takes 90% of the screen
          minChildSize: 0.5, // Minimum 50% when dragged down
          maxChildSize: 0.95, // Maximum 95% of screen height
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle for dragging the sheet
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Header with area name and close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            areaName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  // Map view takes the remaining space
                  Expanded(
                    child: GatheringAreaBottomSheetMapView(
                      areas: areas,
                      initialAreaIndex: initialAreaIndex,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class GatheringAreaSearchDelegate extends SearchDelegate<GatheringArea> {
  final Future<List<GatheringArea>> futureGatheringAreas;

  GatheringAreaSearchDelegate(this.futureGatheringAreas);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(
          context,
          GatheringArea(id: '', geometryName: '', geometry: {}, properties: {}),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<GatheringArea>>(
      future: futureGatheringAreas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Toplanma alanı bulunamadı'));
        }
        final results =
            snapshot.data!.where((area) {
              final areaName =
                  area.properties['ad']?.toString().toLowerCase() ?? '';
              return areaName.contains(query.toLowerCase());
            }).toList();
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final area = results[index];
            final areaName =
                area.properties['ad']?.toString() ?? 'İsimsiz Alan';
            final il = area.properties['il']?.toString() ?? '';
            final ilce = area.properties['ilce']?.toString() ?? '';
            final mahalle = area.properties['mahalle']?.toString() ?? '';
            return ListTile(
              title: Text(areaName),
              subtitle: Text('$il, $ilce, $mahalle'),
              onTap: () {
                close(context, area);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<GatheringArea>>(
      future: futureGatheringAreas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Toplanma alanı bulunamadı'));
        }
        final results =
            snapshot.data!.where((area) {
              final areaName =
                  area.properties['ad']?.toString().toLowerCase() ?? '';
              return areaName.contains(query.toLowerCase());
            }).toList();
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final area = results[index];
            final areaName =
                area.properties['ad']?.toString() ?? 'İsimsiz Alan';
            final il = area.properties['il']?.toString() ?? '';
            final ilce = area.properties['ilce']?.toString() ?? '';
            final mahalle = area.properties['mahalle']?.toString() ?? '';
            return ListTile(
              title: Text(areaName),
              subtitle: Text('$il, $ilce, $mahalle'),
              onTap: () {
                query = areaName;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}

class GatheringAreaMapView extends StatelessWidget {
  GatheringAreaMapView({required this.area});
  final GatheringArea area;

  @override
  Widget build(BuildContext context) {
    // Use try-catch to handle potential errors when accessing coordinates
    try {
      final coordinates = area.geometry['coordinates'];
      if (coordinates == null) {
        return Scaffold(
          appBar: AppBar(
            title: Text(area.properties['ad']?.toString() ?? 'Map View'),
          ),
          body: const Center(child: Text('No coordinate data available')),
        );
      }

      final points = _extractPoints(coordinates);

      final areaName = area.properties['ad']?.toString() ?? 'Map View';
      final il = area.properties['il']?.toString() ?? '';
      final ilce = area.properties['ilce']?.toString() ?? '';
      final mahalle = area.properties['mahalle']?.toString() ?? '';

      return Scaffold(
        appBar: AppBar(title: Text(areaName)),
        body: FlutterMap(
          options: MapOptions(
            onTap: (tapPosition, point) {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Coordinates'),
                    content: Text(
                      'Latitude: ${point.latitude}, Longitude: ${point.longitude}',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            initialZoom: 15,
            initialCenter:
                points.isNotEmpty ? points.first : const LatLng(0, 0),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              // Removed subdomains to avoid the warning
            ),
            PolygonLayer(
              polygons: [
                Polygon(
                  points: points,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha((0.3 * 255).toInt()),
                  borderStrokeWidth: 3,
                  borderColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '$il, $ilce, $mahalle',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      // Return a fallback UI if there's an error
      return Scaffold(
        appBar: AppBar(
          title: Text(area.properties['ad']?.toString() ?? 'Error'),
        ),
        body: Center(child: Text('Error loading map: $e')),
      );
    }
  }

  List<LatLng> _extractPoints(dynamic coordinates) {
    try {
      final coordList = coordinates[0][0] as List?;
      if (coordList == null || coordList.isEmpty) {
        return [];
      }

      return coordList.map((coord) {
        if (coord is List && coord.length >= 2) {
          final lat = (coord[1] as num?)?.toDouble() ?? 0.0;
          final lng = (coord[0] as num?)?.toDouble() ?? 0.0;
          return LatLng(lat, lng);
        }
        return const LatLng(0, 0);
      }).toList();
    } catch (e) {
      print('Error extracting points: $e');
      return [];
    }
  }
}

class GatheringAreaMultiMapView extends StatefulWidget {
  const GatheringAreaMultiMapView({
    Key? key,
    required this.areas,
    required this.initialAreaIndex,
  }) : super(key: key);
  final List<GatheringArea> areas;
  final int initialAreaIndex;

  @override
  _GatheringAreaMultiMapViewState createState() =>
      _GatheringAreaMultiMapViewState();
}

class _GatheringAreaMultiMapViewState extends State<GatheringAreaMultiMapView> {
  late int _selectedAreaIndex;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedAreaIndex = widget.initialAreaIndex;
  }

  List<LatLng> _extractPoints(dynamic coordinates) {
    try {
      final coordList = coordinates[0][0] as List?;
      if (coordList == null || coordList.isEmpty) {
        return [];
      }
      return coordList.map((coord) {
        if (coord is List && coord.length >= 2) {
          final lat = (coord[1] as num?)?.toDouble() ?? 0.0;
          final lng = (coord[0] as num?)?.toDouble() ?? 0.0;
          return LatLng(lat, lng);
        }
        return const LatLng(0, 0);
      }).toList();
    } catch (e) {
      print('Error extracting points: $e');
      return [];
    }
  }

  void _selectArea(int index) {
    setState(() {
      _selectedAreaIndex = index;
    });

    // Get points of the selected area and move the map to its center
    try {
      final area = widget.areas[index];
      final coordinates = area.geometry['coordinates'];
      if (coordinates != null) {
        final points = _extractPoints(coordinates);
        if (points.isNotEmpty) {
          // Find center of polygon
          double avgLat = 0;
          double avgLng = 0;
          for (final point in points) {
            avgLat += point.latitude;
            avgLng += point.longitude;
          }
          avgLat /= points.length;
          avgLng /= points.length;

          _mapController.move(LatLng(avgLat, avgLng), 15);
        }
      }
    } catch (e) {
      print('Error centering map: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedArea = widget.areas[_selectedAreaIndex];
    final areaName = selectedArea.properties['ad']?.toString() ?? 'Map View';
    final allPolygons = <Polygon>[];

    // Add all areas to the map but with different styles based on selection
    for (var i = 0; i < widget.areas.length; i++) {
      try {
        final area = widget.areas[i];
        final coordinates = area.geometry['coordinates'];
        if (coordinates != null) {
          final points = _extractPoints(coordinates);
          if (points.isNotEmpty) {
            allPolygons.add(
              Polygon(
                points: points,
                // Selected area is highlighted in blue, others are gray
                color:
                    i == _selectedAreaIndex
                        ? Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha((0.3 * 255).toInt())
                        : Theme.of(
                          context,
                        ).colorScheme.secondary.withAlpha((0.15 * 255).toInt()),
                borderStrokeWidth: i == _selectedAreaIndex ? 3.0 : 1.0,
                borderColor:
                    i == _selectedAreaIndex
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
              ),
            );
          }
        }
      } catch (e) {
        print('Error creating polygon for area $i: $e');
      }
    }

    // Get initial center of the map based on selected area
    var initialCenter = const LatLng(41.0082, 28.9784); // Default to Istanbul
    try {
      final coordinates = selectedArea.geometry['coordinates'];
      if (coordinates != null) {
        final points = _extractPoints(coordinates);
        if (points.isNotEmpty) {
          initialCenter = points.first;
        }
      }
    } catch (e) {
      print('Error setting initial center: $e');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(areaName),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (context) {
                  return ListView.builder(
                    itemCount: widget.areas.length,
                    itemBuilder: (context, index) {
                      final area = widget.areas[index];
                      final areaName =
                          area.properties['ad']?.toString() ?? 'Unnamed Area';
                      final il = area.properties['il']?.toString() ?? '';
                      final ilce = area.properties['ilce']?.toString() ?? '';

                      return ListTile(
                        title: Text(areaName),
                        subtitle: Text('$il, $ilce'),
                        selected: index == _selectedAreaIndex,
                        onTap: () {
                          Navigator.pop(context); // Close bottom sheet
                          _selectArea(index);
                        },
                      );
                    },
                  );
                },
              );
            },
            tooltip: 'Select Area',
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialZoom: 15,
          initialCenter: initialCenter,
          onTap: (tapPosition, point) {
            // Check if tap is within any polygon and select that area
            for (var i = 0; i < widget.areas.length; i++) {
              try {
                final area = widget.areas[i];
                final coordinates = area.geometry['coordinates'];
                if (coordinates != null) {
                  final points = _extractPoints(coordinates);
                  if (_isPointInPolygon(point, points)) {
                    _selectArea(i);
                    return;
                  }
                }
              } catch (e) {
                print('Error checking point in polygon: $e');
              }
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            // Removed subdomains to avoid the warning
          ),
          PolygonLayer(polygons: allPolygons),
          // Information panel for selected area
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    areaName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${selectedArea.properties['il']}, ${selectedArea.properties['ilce']}, ${selectedArea.properties['mahalle']}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to check if a point is inside a polygon
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    var isInside = false;
    int i = 0;
    int j = polygon.length - 1;

    for (i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude > point.latitude) !=
              (polygon[j].latitude > point.latitude) &&
          (point.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude)) {
        isInside = !isInside;
      }
      j = i;
    }

    return isInside;
  }
}

class GatheringAreaBottomSheetMapView extends StatefulWidget {
  final List<GatheringArea> areas;
  final int initialAreaIndex;

  const GatheringAreaBottomSheetMapView({
    super.key,
    required this.areas,
    required this.initialAreaIndex,
  });

  @override
  _GatheringAreaBottomSheetMapViewState createState() =>
      _GatheringAreaBottomSheetMapViewState();
}

class _GatheringAreaBottomSheetMapViewState
    extends State<GatheringAreaBottomSheetMapView> {
  late int _selectedAreaIndex;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedAreaIndex = widget.initialAreaIndex;
  }

  List<LatLng> _extractPoints(dynamic coordinates) {
    try {
      final coordList = coordinates[0][0] as List?;
      if (coordList == null || coordList.isEmpty) {
        return [];
      }
      return coordList.map((coord) {
        if (coord is List && coord.length >= 2) {
          final lat = (coord[1] as num?)?.toDouble() ?? 0.0;
          final lng = (coord[0] as num?)?.toDouble() ?? 0.0;
          return LatLng(lat, lng);
        }
        return const LatLng(0, 0);
      }).toList();
    } catch (e) {
      print('Error extracting points: $e');
      return [];
    }
  }

  void _selectArea(int index) {
    setState(() {
      _selectedAreaIndex = index;
    });

    // Get points of the selected area and move the map to its center
    try {
      final area = widget.areas[index];
      final coordinates = area.geometry['coordinates'];
      if (coordinates != null) {
        final points = _extractPoints(coordinates);
        if (points.isNotEmpty) {
          // Find center of polygon
          double avgLat = 0;
          double avgLng = 0;
          for (final point in points) {
            avgLat += point.latitude;
            avgLng += point.longitude;
          }
          avgLat /= points.length;
          avgLng /= points.length;

          _mapController.move(LatLng(avgLat, avgLng), 15);
        }
      }
    } catch (e) {
      print('Error centering map: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedArea = widget.areas[_selectedAreaIndex];
    final areaName = selectedArea.properties['ad']?.toString() ?? 'Map View';
    final allPolygons = <Polygon>[];

    // Add all areas to the map but with different styles based on selection
    for (var i = 0; i < widget.areas.length; i++) {
      try {
        final area = widget.areas[i];
        final coordinates = area.geometry['coordinates'];
        if (coordinates != null) {
          final points = _extractPoints(coordinates);
          if (points.isNotEmpty) {
            allPolygons.add(
              Polygon(
                points: points,
                color:
                    i == _selectedAreaIndex
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.15),
                borderStrokeWidth: i == _selectedAreaIndex ? 3.0 : 1.0,
                borderColor:
                    i == _selectedAreaIndex
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
              ),
            );
          }
        }
      } catch (e) {
        print('Error creating polygon for area $i: $e');
      }
    }

    // Get initial center of the map based on selected area
    var initialCenter = const LatLng(41.0082, 28.9784); // Default to Istanbul
    try {
      final coordinates = selectedArea.geometry['coordinates'];
      if (coordinates != null) {
        final points = _extractPoints(coordinates);
        if (points.isNotEmpty) {
          initialCenter = points.first;
        }
      }
    } catch (e) {
      print('Error setting initial center: $e');
    }

    return Column(
      children: [
        // Area selection toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${selectedArea.properties['il'] ?? ''}, ${selectedArea.properties['ilce'] ?? ''}, ${selectedArea.properties['mahalle'] ?? ''}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.list, size: 18),
                label: const Text('Seç'),
                onPressed: () {
                  _showAreaSelectionBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        ),

        // Map takes the remaining space
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialZoom: 15,
                  initialCenter: initialCenter,
                  onTap: (tapPosition, point) {
                    // Check if tap is within any polygon and select that area
                    for (var i = 0; i < widget.areas.length; i++) {
                      try {
                        final area = widget.areas[i];
                        final coordinates = area.geometry['coordinates'];
                        if (coordinates != null) {
                          final points = _extractPoints(coordinates);
                          if (_isPointInPolygon(point, points)) {
                            _selectArea(i);
                            return;
                          }
                        }
                      } catch (e) {
                        print('Error checking point in polygon: $e');
                      }
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  PolygonLayer(polygons: allPolygons),
                ],
              ),

              // Floating panel with area name
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((0.3 * 255).toInt()),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(100),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      areaName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAreaSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Toplanma Alanı Seç',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.areas.length,
                  itemBuilder: (context, index) {
                    final area = widget.areas[index];
                    final areaName =
                        area.properties['ad']?.toString() ?? 'Unnamed Area';
                    final il = area.properties['il']?.toString() ?? '';
                    final ilce = area.properties['ilce']?.toString() ?? '';
                    final mahalle =
                        area.properties['mahalle']?.toString() ?? '';

                    return ListTile(
                      title: Text(areaName),
                      subtitle: Text('$il, $ilce, $mahalle'),
                      selected: index == _selectedAreaIndex,
                      onTap: () {
                        Navigator.pop(context);
                        _selectArea(index);
                      },
                      trailing:
                          index == _selectedAreaIndex
                              ? const Icon(Icons.check_circle)
                              : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to check if a point is inside a polygon
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    var isInside = false;
    int i = 0;
    int j = polygon.length - 1;

    for (i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude > point.latitude) !=
              (polygon[j].latitude > point.latitude) &&
          (point.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude)) {
        isInside = !isInside;
      }
      j = i;
    }

    return isInside;
  }
}
