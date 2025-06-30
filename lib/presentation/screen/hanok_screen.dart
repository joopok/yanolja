import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '한옥',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                color: Colors.white,
                child: Column(
                  children: [
                    // 스타일 필터
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _styles.length,
                        itemBuilder: (context, index) {
                          final style = _styles[index];
                          final isSelected = _selectedStyle == style;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(style),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedStyle = selected ? style : '전체';
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
                    // 정렬 옵션
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${hanoks.length}개의 한옥',
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
              // 한옥 리스트
              Expanded(
                child: hanoks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '조건에 맞는 한옥이 없습니다',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '다른 조건으로 검색해보세요',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: hanoks.length,
                          itemBuilder: (context, index) {
                            final hanok = hanoks[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                '오류가 발생했습니다',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
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

// 한옥 리스트 아이템 위젯
class _HanokListItem extends ConsumerWidget {
  final Accommodation hanok;

  const _HanokListItem({required this.hanok});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(savedProvider).contains(hanok.id);

    return GestureDetector(
      onTap: () => context.push('/detail/${hanok.id}'),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 섹션
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: hanok.imageUrls.isNotEmpty 
                        ? hanok.imageUrls.first 
                        : 'https://images.unsplash.com/photo-1540479859555-17af45c78602?w=800',
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (hanok.isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '인기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
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
                      size: 28,
                    ),
                    onPressed: () {
                      ref.read(savedProvider.notifier).toggleSaved(hanok.id);
                    },
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hanok.name,
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
                            hanok.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' (${hanok.reviewCount})',
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
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hanok.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 설명
                  Text(
                    hanok.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // 태그들
                  if (hanok.tags != null && hanok.tags!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: hanok.tags!.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.brown[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.brown[200]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.brown[700],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  // 가격과 편의시설
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: NumberFormat('#,###').format(hanok.price),
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
                      Row(
                        children: [
                          if (hanok.hasWifi)
                            Icon(Icons.wifi, size: 20, color: Colors.grey[600]),
                          if (hanok.hasParking) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.local_parking, size: 20, color: Colors.grey[600]),
                          ],
                          if (hanok.hasBreakfast) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.restaurant, size: 20, color: Colors.grey[600]),
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