
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/saved_provider.dart';

class ResortScreen extends ConsumerStatefulWidget {
  const ResortScreen({super.key});

  @override
  ConsumerState<ResortScreen> createState() => _ResortScreenState();
}

class _ResortScreenState extends ConsumerState<ResortScreen> {
  String _selectedFilter = '전체';
  String _sortBy = '추천순';
  final List<String> _filters = ['전체', '풀빌라', '스위트룸', '오션뷰', '스파'];
  final List<String> _sortOptions = ['추천순', '낮은가격순', '높은가격순', '평점순'];

  @override
  Widget build(BuildContext context) {
    final accommodationsAsync = ref.watch(accommodationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '리조트',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => _sortOptions
                .map((option) => PopupMenuItem(
                      value: option,
                      child: Row(
                        children: [
                          if (_sortBy == option)
                            Icon(Icons.check_rounded, 
                                size: 20, 
                                color: Theme.of(context).colorScheme.primary),
                          if (_sortBy == option) const SizedBox(width: 8),
                          Text(option),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: accommodationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('에러: $err')),
              data: (accommodations) {
                final resorts = _filterAndSortAccommodations(
                    accommodations.where((acc) => acc.category == '리조트').toList());
                
                if (resorts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.beach_access_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('해당하는 리조트가 없습니다', 
                             style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: resorts.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 300),
                        child: SlideAnimation(
                          verticalOffset: 20.0,
                          child: FadeInAnimation(
                            child: _buildResortCard(context, resorts[index]),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.transparent,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResortCard(BuildContext context, Accommodation resort) {
    final formatter = NumberFormat('#,###');
    final isSaved = ref.watch(savedProvider).contains(resort.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/detail/${resort.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 섹션
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: resort.imageUrls.first,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error, size: 50),
                    ),
                  ),
                ),
                // 리조트 특별 배지
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🏖️ 리조트',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // 찜하기 버튼
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    onPressed: () {
                      ref.read(savedProvider.notifier).toggleSaved(resort.id);
                    },
                    icon: Icon(
                      isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isSaved ? Colors.red : Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                // 이미지 개수 표시
                if (resort.imageUrls.length > 1)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '📷 ${resort.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // 정보 섹션
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목과 평점
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          resort.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              resort.rating.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 위치
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, 
                           size: 16, 
                           color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          resort.address,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 리조트 특별 편의시설
                  if (resort.amenities.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: resort.amenities.take(3).map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            amenity,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),
                  // 가격 정보
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1박 기준',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${formatter.format(resort.price)}원',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${resort.reviewCount}개 후기',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
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
    );
  }

  List<Accommodation> _filterAndSortAccommodations(List<Accommodation> accommodations) {
    List<Accommodation> filtered = accommodations;

    // 필터링
    if (_selectedFilter != '전체') {
      filtered = filtered.where((acc) {
        switch (_selectedFilter) {
          case '풀빌라':
            return acc.amenities.any((amenity) => 
                amenity.contains('풀') || amenity.contains('수영장'));
          case '스위트룸':
            return acc.name.contains('스위트') || acc.amenities.contains('스위트룸');
          case '오션뷰':
            return acc.amenities.any((amenity) => 
                amenity.contains('오션뷰') || amenity.contains('바다'));
          case '스파':
            return acc.amenities.any((amenity) => 
                amenity.contains('스파') || amenity.contains('사우나'));
          default:
            return true;
        }
      }).toList();
    }

    // 정렬
    switch (_sortBy) {
      case '낮은가격순':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case '높은가격순':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case '평점순':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case '추천순':
      default:
        filtered.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }

    return filtered;
  }
}
