import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_bottom_nav.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';

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
  final PageController _pageController = PageController(viewportFraction: 0.9);
  GoogleMapController? _mapController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accommodations != widget.accommodations) {
      _selectedIndex = 0;
      _addMarkers();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _addMarkers() {
    _markers.clear();
    for (var i = 0; i < widget.accommodations.length; i++) {
      final acc = widget.accommodations[i];
      if (acc.latitude == null || acc.longitude == null) continue;

      final markerId = MarkerId(acc.id);
      final rate = YanoljaFormat.discountRate(acc.id);
      final marker = Marker(
        markerId: markerId,
        position: LatLng(acc.latitude!, acc.longitude!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: acc.name,
          snippet: '$rate% ${YanoljaFormat.price(acc.price)}원~',
        ),
        onTap: () => _selectAccommodation(i),
      );
      _markers[markerId] = marker;
    }
  }

  LatLng _initialTarget() {
    if (widget.initialCameraPosition != null) {
      return widget.initialCameraPosition!;
    }

    for (final acc in widget.accommodations) {
      if (acc.latitude != null && acc.longitude != null) {
        return LatLng(acc.latitude!, acc.longitude!);
      }
    }

    return const LatLng(37.5665, 126.9780);
  }

  void _selectAccommodation(int index) {
    if (index < 0 || index >= widget.accommodations.length) return;
    setState(() => _selectedIndex = index);

    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    }

    final acc = widget.accommodations[index];
    if (acc.latitude != null && acc.longitude != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(acc.latitude!, acc.longitude!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.accommodations.isEmpty) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      appBar: YanoljaAppBar.sub(
        title: '지도',
        subtitle: '지도에서 숙소 ${widget.accommodations.length}개 보기',
        fallbackRoute: '/nearby',
      ),
      bottomNavigationBar: const YanoljaBottomNav(selectedBranchIndex: 2),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialTarget(),
              zoom: 12.0,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: Set<Marker>.of(_markers.values),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: _MapSearchHeader(count: widget.accommodations.length),
          ),
          Positioned(
            right: 16,
            top: 78,
            child: _MapToolButton(
              icon: Icons.my_location_rounded,
              label: '내 위치',
              onTap: () {
                HapticFeedback.lightImpact();
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(_initialTarget()),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: SizedBox(
              height: 168,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.accommodations.length,
                onPageChanged: _selectAccommodation,
                itemBuilder: (context, index) {
                  final accommodation = widget.accommodations[index];
                  return _MapAccommodationCard(
                    accommodation: accommodation,
                    selected: index == _selectedIndex,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/detail/${accommodation.id}');
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: YanoljaColors.background,
      appBar: const YanoljaAppBar.sub(
        title: '지도',
        fallbackRoute: '/nearby',
      ),
      bottomNavigationBar: const YanoljaBottomNav(selectedBranchIndex: 2),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: YanoljaColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.map_outlined,
                color: YanoljaColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '지도에 표시할 숙소가 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '다른 검색어로 다시 찾아보세요',
              style: TextStyle(
                fontSize: 13.5,
                color: YanoljaColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapSearchHeader extends StatelessWidget {
  final int count;

  const _MapSearchHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        border: Border.all(color: YanoljaColors.border),
        boxShadow: const [
          BoxShadow(
            color: YanoljaColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: YanoljaColors.textPrimary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '지도에서 숙소 $count개 보기',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: YanoljaColors.primaryLight,
              borderRadius: BorderRadius.circular(YanoljaRadius.pill),
            ),
            child: const Text(
              'NOL특가',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MapToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: YanoljaColors.shadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: YanoljaColors.textPrimary, size: 22),
        ),
      ),
    );
  }
}

class _MapAccommodationCard extends StatelessWidget {
  final Accommodation accommodation;
  final bool selected;
  final VoidCallback onTap;

  const _MapAccommodationCard({
    required this.accommodation,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rate = YanoljaFormat.discountRate(accommodation.id);
    final original = YanoljaFormat.originalPrice(accommodation.price, rate);
    final imageUrl =
        accommodation.imageUrls.isNotEmpty ? accommodation.imageUrls.first : '';

    return AnimatedScale(
      scale: selected ? 1 : 0.97,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(YanoljaRadius.lg),
              border: Border.all(
                color: selected
                    ? YanoljaColors.primaryLight
                    : YanoljaColors.border,
                width: selected ? 1.4 : 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: YanoljaColors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 110,
                    height: 132,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 110,
                      height: 132,
                      color: YanoljaColors.surfaceAlt,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 110,
                      height: 132,
                      color: YanoljaColors.surfaceAlt,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: YanoljaColors.textTertiary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: YanoljaColors.textPrimary,
                              borderRadius:
                                  BorderRadius.circular(YanoljaRadius.sm),
                            ),
                            child: const Text(
                              '많이 찾는 숙소',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        accommodation.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          height: 1.22,
                          fontWeight: FontWeight.w900,
                          color: YanoljaColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      YanoljaRating(
                        rating: accommodation.rating,
                        reviewCount: accommodation.reviewCount,
                        fontSize: 12,
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$rate%',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: YanoljaColors.sale,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${YanoljaFormat.price(original)}원',
                            style: const TextStyle(
                              fontSize: 11,
                              color: YanoljaColors.textTertiary,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: YanoljaColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            YanoljaFormat.price(accommodation.price),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: YanoljaColors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const Text(
                            '원~',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: YanoljaColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
