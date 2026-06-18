import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/saved_provider.dart';

class PensionScreen extends ConsumerStatefulWidget {
  const PensionScreen({super.key});

  @override
  ConsumerState<PensionScreen> createState() => _PensionScreenState();
}

class _PensionScreenState extends ConsumerState<PensionScreen> {
  String _selectedTheme = '전체';
  String _sortBy = '추천순';
  String _selectedSeason = '전체';
  final List<String> _themes = ['전체', '가족', '연인'];
  final List<String> _seasons = ['전체', '봄', '여름', '가을', '겨울'];
  final List<String> _sortOptions = ['추천순', '낮은가격순', '높은가격순', '평점순'];

  @override
  Widget build(BuildContext context) {
    final accommodationsAsync = ref.watch(accommodationListProvider);

    return Scaffold(
      backgroundColor: YanoljaColors.background,
      appBar: AppBar(
        title: const Text('펜션'),
      ),
      body: accommodationsAsync.when(
        data: (accommodations) {
          // 펜션만 필터링
          var pensions = accommodations
              .where((accommodation) => accommodation.category == '펜션')
              .toList();

          // 테마 필터링
          if (_selectedTheme != '전체') {
            pensions = pensions
                .where((pension) => pension.theme == _selectedTheme)
                .toList();
          }

          // 정렬
          switch (_sortBy) {
            case '낮은가격순':
              pensions.sort((a, b) => a.price.compareTo(b.price));
              break;
            case '높은가격순':
              pensions.sort((a, b) => b.price.compareTo(a.price));
              break;
            case '평점순':
              pensions.sort((a, b) => b.rating.compareTo(a.rating));
              break;
          }

          return Column(
            children: [
              // 필터 섹션
              Container(
                color: YanoljaColors.background,
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Column(
                  children: [
                    // 테마 필터
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _themes.length,
                        itemBuilder: (context, index) {
                          final theme = _themes[index];
                          return _FilterChip(
                            label: theme,
                            isSelected: _selectedTheme == theme,
                            onTap: () {
                              setState(() => _selectedTheme = theme);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 계절 필터
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _seasons.length,
                        itemBuilder: (context, index) {
                          final season = _seasons[index];
                          return _FilterChip(
                            label: season,
                            isSelected: _selectedSeason == season,
                            onTap: () {
                              setState(() => _selectedSeason = season);
                            },
                          );
                        },
                      ),
                    ),
                    // 정렬 옵션
                    Container(
                      padding:
                          const EdgeInsets.fromLTRB(20, 8, 12, 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${pensions.length}개의 펜션',
                            style: const TextStyle(
                              fontSize: 13,
                              color: YanoljaColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          DropdownButton<String>(
                            value: _sortBy,
                            underline: const SizedBox(),
                            icon: const Icon(
                              Icons.expand_more_rounded,
                              size: 18,
                              color: YanoljaColors.textSecondary,
                            ),
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: YanoljaColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            items: _sortOptions.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _sortBy = value!);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 섹션 구분 띠
              Container(height: 8, color: YanoljaColors.surfaceAlt),
              // 펜션 리스트
              Expanded(
                child: pensions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.house_outlined,
                              size: 72,
                              color: YanoljaColors.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '조건에 맞는 펜션이 없습니다',
                              style: TextStyle(
                                fontSize: 15,
                                color: YanoljaColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          itemCount: pensions.length,
                          itemBuilder: (context, index) {
                            final pension = pensions[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 300),
                              child: SlideAnimation(
                                verticalOffset: 20.0,
                                child: FadeInAnimation(
                                  child: _PensionListItem(
                                    pension: pension,
                                    selectedSeason: _selectedSeason,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: YanoljaColors.primary),
        ),
        error: (error, stack) => Center(
          child: Text('오류가 발생했습니다: $error'),
        ),
      ),
    );
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
            color: isSelected
                ? YanoljaColors.primary
                : YanoljaColors.background,
            borderRadius: BorderRadius.circular(YanoljaRadius.pill),
            border: Border.all(
              color: isSelected
                  ? YanoljaColors.primary
                  : YanoljaColors.border,
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

// 펜션 리스트 아이템 위젯
class _PensionListItem extends ConsumerStatefulWidget {
  final Accommodation pension;
  final String selectedSeason;

  const _PensionListItem({
    required this.pension,
    required this.selectedSeason,
  });

  @override
  ConsumerState<_PensionListItem> createState() => _PensionListItemState();
}

class _PensionListItemState extends ConsumerState<_PensionListItem> {
  int _currentImageIndex = 0;
  final carousel_slider.CarouselSliderController _carouselController =
      carousel_slider.CarouselSliderController();

  List<String> _getSeasonImages() {
    if (widget.selectedSeason == '전체' ||
        widget.pension.seasonalImages == null) {
      return widget.pension.imageUrls;
    }

    final seasonMap = {
      '봄': widget.pension.seasonalImages!.spring,
      '여름': widget.pension.seasonalImages!.summer,
      '가을': widget.pension.seasonalImages!.autumn,
      '겨울': widget.pension.seasonalImages!.winter,
    };

    return seasonMap[widget.selectedSeason] ?? widget.pension.imageUrls;
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = ref.watch(savedProvider).contains(widget.pension.id);
    final images = _getSeasonImages();
    final rate = YanoljaFormat.discountRate(widget.pension.id);
    final original = YanoljaFormat.originalPrice(widget.pension.price, rate);

    return GestureDetector(
      onTap: () => context.push('/detail/${widget.pension.id}'),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 캐러셀
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(YanoljaRadius.lg),
                  ),
                  child: carousel_slider.CarouselSlider(
                    carouselController: _carouselController,
                    options: carousel_slider.CarouselOptions(
                      height: 190,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: images.length > 1,
                      onPageChanged: (index, reason) {
                        setState(() => _currentImageIndex = index);
                      },
                    ),
                    items: images.map((imageUrl) {
                      return CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: 190,
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
                      );
                    }).toList(),
                  ),
                ),
                // 이미지 인디케이터
                if (images.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: images.asMap().entries.map((entry) {
                        final active = _currentImageIndex == entry.key;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: active ? 16 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: active
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                // 계절 태그
                if (widget.selectedSeason != '전체')
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
                      child: Text(
                        widget.selectedSeason,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                // 찜 버튼
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved ? YanoljaColors.primary : Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      ref
                          .read(savedProvider.notifier)
                          .toggleSaved(widget.pension.id);
                    },
                  ),
                ),
              ],
            ),
            // 펜션 정보
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이름과 NEW 배지
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.pension.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: YanoljaColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.pension.isNew) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: YanoljaColors.primaryLight,
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.sm),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: YanoljaColors.primary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 평점
                  YanoljaRating(
                    rating: widget.pension.rating,
                    reviewCount: widget.pension.reviewCount,
                  ),
                  const SizedBox(height: 6),
                  // 주소
                  Text(
                    widget.pension.address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: YanoljaColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // 테마 + 태그
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (widget.pension.theme != null)
                        _InfoTag(
                          label: widget.pension.theme!,
                          highlighted: true,
                        ),
                      if (widget.pension.tags != null)
                        ...widget.pension.tags!
                            .take(3)
                            .map((tag) => _InfoTag(label: tag)),
                    ],
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
                      Text(
                        '${YanoljaFormat.price(widget.pension.price)}원',
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
            ),
          ],
        ),
      ),
    );
  }
}

/// 정보 태그 — 강조(핑크 틴트) 또는 기본(그레이)
class _InfoTag extends StatelessWidget {
  final String label;
  final bool highlighted;

  const _InfoTag({required this.label, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color:
            highlighted ? YanoljaColors.primaryLight : YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(YanoljaRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          color:
              highlighted ? YanoljaColors.primary : YanoljaColors.textSecondary,
          fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
