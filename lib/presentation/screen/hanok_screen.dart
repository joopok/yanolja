import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/saved_provider.dart';

class HanokScreen extends ConsumerStatefulWidget {
  const HanokScreen({super.key});

  @override
  ConsumerState<HanokScreen> createState() => _HanokScreenState();
}

class _HanokScreenState extends ConsumerState<HanokScreen> {
  String _selectedStyle = '전체';
  String _sortBy = '추천순';
  final List<String> _styles = ['전체', '전통', '모던', '프리미엄', '한옥스테이'];
  final List<String> _sortOptions = ['추천순', '낮은가격순', '높은가격순', '평점순'];

  @override
  Widget build(BuildContext context) {
    final accommodationsAsync = ref.watch(accommodationListProvider);

    return Scaffold(
      backgroundColor: YanoljaColors.background,
      appBar: AppBar(
        title: const Text(
          '한옥',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
      ),
      body: accommodationsAsync.when(
        data: (accommodations) {
          // 한옥만 필터링 (category가 '한옥'인 것)
          var hanoks = accommodations
              .where((accommodation) =>
                  accommodation.category.contains('한옥') ||
                  accommodation.name.contains('한옥'))
              .toList();

          // 스타일 필터링
          if (_selectedStyle != '전체') {
            hanoks = hanoks.where((hanok) {
              switch (_selectedStyle) {
                case '전통':
                  return hanok.tags?.contains('전통') ?? false;
                case '모던':
                  return hanok.tags?.contains('모던') ?? false;
                case '프리미엄':
                  return hanok.isPopular || (hanok.price > 200000);
                case '한옥스테이':
                  return hanok.tags?.contains('체험') ?? false;
                default:
                  return true;
              }
            }).toList();
          }

          // 정렬
          switch (_sortBy) {
            case '낮은가격순':
              hanoks.sort((a, b) => a.price.compareTo(b.price));
              break;
            case '높은가격순':
              hanoks.sort((a, b) => b.price.compareTo(a.price));
              break;
            case '평점순':
              hanoks.sort((a, b) => b.rating.compareTo(a.rating));
              break;
          }

          return Column(
            children: [
              // 필터 섹션
              Container(
                color: YanoljaColors.background,
                child: Column(
                  children: [
                    // 스타일 필터
                    SizedBox(
                      height: 52,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: _styles.length,
                        itemBuilder: (context, index) {
                          final style = _styles[index];
                          final isSelected = _selectedStyle == style;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _StyleChip(
                              label: style,
                              selected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedStyle =
                                      isSelected ? '전체' : style;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // 정렬 옵션
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${hanoks.length}개의 한옥',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: YanoljaColors.textSecondary,
                            ),
                          ),
                          DropdownButton<String>(
                            value: _sortBy,
                            underline: const SizedBox(),
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.md),
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: YanoljaColors.textSecondary,
                            ),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: YanoljaColors.textPrimary,
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
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: YanoljaColors.border,
                    ),
                  ],
                ),
              ),
              // 한옥 리스트
              Expanded(
                child: hanoks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.home_outlined,
                              size: 72,
                              color: YanoljaColors.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '조건에 맞는 한옥이 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: YanoljaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '다른 조건으로 검색해보세요',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: YanoljaColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          itemCount: hanoks.length,
                          itemBuilder: (context, index) {
                            final hanok = hanoks[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 300),
                              child: SlideAnimation(
                                verticalOffset: 20.0,
                                child: FadeInAnimation(
                                  child: _HanokListItem(hanok: hanok),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: YanoljaColors.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                '오류가 발생했습니다',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: YanoljaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: YanoljaColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 야놀자 스타일 필터 칩 (플랫 핑크)
class _StyleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StyleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? YanoljaColors.primary : YanoljaColors.surfaceAlt,
          borderRadius: BorderRadius.circular(YanoljaRadius.pill),
          border: Border.all(
            color: selected ? YanoljaColors.primary : YanoljaColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : YanoljaColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// 한옥 리스트 아이템 위젯
class _HanokListItem extends ConsumerWidget {
  final Accommodation hanok;

  const _HanokListItem({required this.hanok});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(savedProvider).contains(hanok.id);

    // 야놀자 스타일 가격 표기 (정가 취소선 + 핑크 할인율 + 굵은 현재가)
    final discountRate = YanoljaFormat.discountRate(hanok.id);
    final originalPrice =
        YanoljaFormat.originalPrice(hanok.price, discountRate);

    return GestureDetector(
      onTap: () => context.push('/detail/${hanok.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: YanoljaColors.surface,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border, width: 1),
          boxShadow: const [
            BoxShadow(
              color: YanoljaColors.shadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 섹션
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(YanoljaRadius.lg)),
                  child: CachedNetworkImage(
                    imageUrl: hanok.imageUrls.isNotEmpty
                        ? hanok.imageUrls.first
                        : 'https://images.unsplash.com/photo-1540479859555-17af45c78602?w=800',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: YanoljaColors.surfaceAlt,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: YanoljaColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
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
                // 뱃지들
                Positioned(
                  top: 12,
                  left: 12,
                  child: Row(
                    children: [
                      if (hanok.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: YanoljaColors.primary,
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.sm),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      if (hanok.isPopular) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: YanoljaColors.textPrimary
                                .withValues(alpha: 0.78),
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.sm),
                          ),
                          child: const Text(
                            '인기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 찜 버튼
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(savedProvider.notifier).toggleSaved(hanok.id);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSaved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isSaved
                            ? YanoljaColors.primary
                            : YanoljaColors.textSecondary,
                        size: 22,
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
                  // 이름과 평점
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          hanok.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: YanoljaColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      YanoljaRating(
                        rating: hanok.rating,
                        reviewCount: hanok.reviewCount,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 주소
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: YanoljaColors.textTertiary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          hanok.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: YanoljaColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 설명
                  Text(
                    hanok.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: YanoljaColors.textSecondary,
                      height: 1.45,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // 태그들
                  if (hanok.tags != null && hanok.tags!.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: hanok.tags!.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: YanoljaColors.primaryLight,
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.sm),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: YanoljaColors.primaryDark,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 14),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: YanoljaColors.divider,
                  ),
                  const SizedBox(height: 12),
                  // 가격과 편의시설
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 정가 취소선
                          Text(
                            '${YanoljaFormat.price(originalPrice)}원',
                            style: const TextStyle(
                              fontSize: 12,
                              color: YanoljaColors.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // 할인율 + 현재가
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$discountRate%',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: YanoljaColors.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                YanoljaFormat.price(hanok.price),
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: YanoljaColors.textPrimary,
                                ),
                              ),
                              const Text(
                                '원',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: YanoljaColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (hanok.hasWifi)
                            const Icon(Icons.wifi_rounded,
                                size: 18, color: YanoljaColors.textTertiary),
                          if (hanok.hasParking) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.local_parking_rounded,
                                size: 18, color: YanoljaColors.textTertiary),
                          ],
                          if (hanok.hasBreakfast) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.restaurant_rounded,
                                size: 18, color: YanoljaColors.textTertiary),
                          ],
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
    );
  }
}
