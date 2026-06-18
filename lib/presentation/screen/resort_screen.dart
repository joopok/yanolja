import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
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
      backgroundColor: YanoljaColors.background,
      appBar: AppBar(
        title: const Text('리조트'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.sort_rounded,
              color: YanoljaColors.textPrimary,
            ),
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => _sortOptions
                .map((option) => PopupMenuItem(
                      value: option,
                      child: Row(
                        children: [
                          if (_sortBy == option)
                            const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: YanoljaColors.primary,
                            ),
                          if (_sortBy == option) const SizedBox(width: 8),
                          Text(
                            option,
                            style: TextStyle(
                              color: _sortBy == option
                                  ? YanoljaColors.primary
                                  : YanoljaColors.textPrimary,
                              fontWeight: _sortBy == option
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
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
          Container(height: 8, color: YanoljaColors.surfaceAlt),
          Expanded(
            child: accommodationsAsync.when(
              loading: () => const Center(
                child:
                    CircularProgressIndicator(color: YanoljaColors.primary),
              ),
              error: (err, stack) => Center(child: Text('에러: $err')),
              data: (accommodations) {
                final resorts = _filterAndSortAccommodations(accommodations
                    .where((acc) => acc.category == '리조트')
                    .toList());

                if (resorts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.beach_access_outlined,
                          size: 64,
                          color: YanoljaColors.textTertiary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '해당하는 리조트가 없습니다',
                          style: TextStyle(
                            fontSize: 15,
                            color: YanoljaColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
      color: YanoljaColors.background,
      height: 56,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          return _FilterChip(
            label: filter,
            isSelected: _selectedFilter == filter,
            onTap: () {
              setState(() => _selectedFilter = filter);
            },
          );
        },
      ),
    );
  }

  Widget _buildResortCard(BuildContext context, Accommodation resort) {
    final isSaved = ref.watch(savedProvider).contains(resort.id);
    final rate = YanoljaFormat.discountRate(resort.id);
    final original = YanoljaFormat.originalPrice(resort.price, rate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: YanoljaColors.surface,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        border: Border.all(color: YanoljaColors.border),
        boxShadow: const [
          BoxShadow(
            color: YanoljaColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/detail/${resort.id}'),
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 섹션
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(YanoljaRadius.lg),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: resort.imageUrls.first,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: YanoljaColors.surfaceAlt,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: YanoljaColors.surfaceAlt,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 44,
                          color: YanoljaColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  // 리조트 배지
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: YanoljaColors.primary,
                        borderRadius:
                            BorderRadius.circular(YanoljaRadius.sm),
                      ),
                      child: const Text(
                        '리조트',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  // 찜하기 버튼
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () {
                        ref
                            .read(savedProvider.notifier)
                            .toggleSaved(resort.id);
                      },
                      icon: Icon(
                        isSaved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color:
                            isSaved ? YanoljaColors.primary : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  // 이미지 개수 표시
                  if (resort.imageUrls.length > 1)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius:
                              BorderRadius.circular(YanoljaRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_library_outlined,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${resort.imageUrls.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // 정보 섹션
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      resort.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: YanoljaColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // 평점
                    YanoljaRating(
                      rating: resort.rating,
                      reviewCount: resort.reviewCount,
                    ),
                    const SizedBox(height: 6),
                    // 위치
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: YanoljaColors.textTertiary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            resort.address,
                            style: const TextStyle(
                              fontSize: 13,
                              color: YanoljaColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // 편의시설 태그
                    if (resort.amenities.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: resort.amenities.take(3).map((amenity) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: YanoljaColors.surfaceAlt,
                              borderRadius:
                                  BorderRadius.circular(YanoljaRadius.sm),
                            ),
                            child: Text(
                              amenity,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: YanoljaColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 12),
                    // 가격: 할인율 + 정가(취소선) + 현재가
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$rate%',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: YanoljaColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${YanoljaFormat.price(original)}원',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: YanoljaColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '1박 기준',
                              style: TextStyle(
                                fontSize: 11,
                                color: YanoljaColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              '${YanoljaFormat.price(resort.price)}원',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: YanoljaColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
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
    );
  }

  List<Accommodation> _filterAndSortAccommodations(
      List<Accommodation> accommodations) {
    List<Accommodation> filtered = accommodations;

    // 필터링
    if (_selectedFilter != '전체') {
      filtered = filtered.where((acc) {
        switch (_selectedFilter) {
          case '풀빌라':
            return acc.amenities.any((amenity) =>
                amenity.contains('풀') || amenity.contains('수영장'));
          case '스위트룸':
            return acc.name.contains('스위트') ||
                acc.amenities.contains('스위트룸');
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

/// 야놀자 플랫 필터칩 — 선택 시 핑크 필, 미선택 시 화이트 + 헤어라인 보더
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color:
                isSelected ? YanoljaColors.primary : YanoljaColors.background,
            borderRadius: BorderRadius.circular(YanoljaRadius.pill),
            border: Border.all(
              color:
                  isSelected ? YanoljaColors.primary : YanoljaColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              color: isSelected ? Colors.white : YanoljaColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
