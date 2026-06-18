import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';

class MapScreen extends ConsumerStatefulWidget {
  final List<Accommodation> accommodations;
  final LatLng? initialCameraPosition;

  const MapScreen({
    super.key,
    required this.accommodations,
    this.initialCameraPosition,
  });

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Map<MarkerId, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  void _addMarkers() {
    _markers.clear();
    for (var acc in widget.accommodations) {
      if (acc.latitude != null && acc.longitude != null) {
        final markerId = MarkerId(acc.id);
        final marker = Marker(
          markerId: markerId,
          position: LatLng(acc.latitude!, acc.longitude!),
          infoWindow: InfoWindow(
            title: acc.name,
            snippet: acc.address,
            onTap: () {
              // TODO: 숙소 상세 페이지로 이동
              debugPrint('Tapped on ${acc.name}');
            },
          ),
        );
        _markers[markerId] = marker;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('지도 보기'),
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surface,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialCameraPosition ?? const LatLng(37.5665, 126.9780), // 서울 시청
          zoom: 10.0,
        ),
        markers: Set<Marker>.of(_markers.values),
      ),
    );
  }
}
