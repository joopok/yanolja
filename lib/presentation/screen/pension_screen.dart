import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '펜션',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
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
                color: Colors.white,
                child: Column(
                  children: [
                    // 테마 필터
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _themes.length,
                        itemBuilder: (context, index) {
                          final theme = _themes[index];
                          final isSelected = _selectedTheme == theme;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(theme),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedTheme = selected ? theme : '전체';
                                });
                              },
                              selectedColor: Theme.of(context).primaryColor,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // 계절 필터
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _seasons.length,
                        itemBuilder: (context, index) {
                          final season = _seasons[index];
                          final isSelected = _selectedSeason == season;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(season),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSeason = selected ? season : '전체';
                                });
                              },
                              selectedColor: Theme.of(context).colorScheme.secondary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // 정렬 옵션
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${pensions.length}개의 펜션',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          DropdownButton<String>(
                            value: _sortBy,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            items: _sortOptions.map((option) {
                              return DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _sortBy = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 펜션 리스트
              Expanded(
                child: pensions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.house_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '조건에 맞는 펜션이 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('오류가 발생했습니다: $error'),
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
  final carousel_slider.CarouselSliderController _carouselController = carousel_slider.CarouselSliderController();

  List<String> _getSeasonImages() {
    if (widget.selectedSeason == '전체' || widget.pension.seasonalImages == null) {
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

    return GestureDetector(
      onTap: () => context.push('/detail/${widget.pension.id}'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 캐러셀
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: carousel_slider.CarouselSlider(
                    carouselController: _carouselController,
                    options: carousel_slider.CarouselOptions(
                      height: 200,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: images.length > 1,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                    items: images.map((imageUrl) {
                      return CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // 이미지 인디케이터
                if (images.length > 1)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: images.asMap().entries.map((entry) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == entry.key
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getSeasonColor(widget.selectedSeason),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.selectedSeason,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // 찜 버튼
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    icon: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(savedProvider.notifier).toggleSaved(widget.pension.id);
                    },
                  ),
                ),
              ],
            ),
            // 펜션 정보
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이름과 평점
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.pension.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            widget.pension.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' (${widget.pension.reviewCount})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 주소
                  Text(
                    widget.pension.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 테마 태그
                  if (widget.pension.theme != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.pension.theme == '가족'
                            ? Colors.blue[50]
                            : Colors.pink[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.pension.theme!,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.pension.theme == '가족'
                              ? Colors.blue[700]
                              : Colors.pink[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  // 태그들
                  if (widget.pension.tags != null && widget.pension.tags!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.pension.tags!.take(3).map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: Colors.grey[100],
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),
                  // 가격
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: NumberFormat('#,###').format(widget.pension.price),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const TextSpan(
                              text: '원',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.pension.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
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

  Color _getSeasonColor(String season) {
    switch (season) {
      case '봄':
        return Colors.pink[300]!;
      case '여름':
        return Colors.blue[400]!;
      case '가을':
        return Colors.orange[400]!;
      case '겨울':
        return Colors.blueGrey[400]!;
      default:
        return Colors.grey;
    }
  }
}