import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 햅틱 피드백용
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'; // 무한 스크롤용
import 'package:shimmer/shimmer.dart'; // 스켈레톤 로딩용
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/saved_provider.dart';

// 🚀 페이지 크기 설정
const int _pageSize = 10;

// 🔧 기존 provider를 유지하되 추가로 페이지네이션용 provider 생성
final hotelAccommodationsProvider = FutureProvider<List<Accommodation>>((ref) async {
  final accommodations = await ref.watch(accommodationListProvider.future);
  return accommodations.where((acc) => acc.category == '호텔').toList();
});

class HotelScreen extends ConsumerStatefulWidget {
  const HotelScreen({super.key});

  @override
  ConsumerState<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends ConsumerState<HotelScreen> {
  // 무한 스크롤 컨트롤러
  final PagingController<int, Accommodation> _pagingController =
      PagingController(firstPageKey: 0);

  String _sortBy = 'rating';
  String? _selectedRegion;
  final List<String> _regions = ['전체', '서울', '부산', '제주', '강릉', '여수', '경주'];

  // 전체 호텔 데이터 캐시
  List<Accommodation> _allHotels = [];

  @override
  void initState() {
    super.initState();

    // 페이지네이션 설정
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  /// 페이지 단위로 데이터 로드
  Future<void> _fetchPage(int pageKey) async {
    try {
      // 전체 호텔 데이터가 아직 로드되지 않았다면 로드
      if (_allHotels.isEmpty) {
        final allAccommodations = await ref.read(accommodationListProvider.future);
        _allHotels = allAccommodations.where((acc) => acc.category == '호텔').toList();
      }

      // 정렬 및 필터링 적용
      final filteredHotels = _sortAndFilterHotels(_allHotels);

      // 페이지네이션 적용
      final startIndex = pageKey;
      final endIndex = startIndex + _pageSize;

      final pageItems = filteredHotels.skip(startIndex).take(_pageSize).toList();

      final isLastPage = endIndex >= filteredHotels.length;
      if (isLastPage) {
        _pagingController.appendLastPage(pageItems);
      } else {
        final nextPageKey = endIndex;
        _pagingController.appendPage(pageItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  /// 필터나 정렬이 변경될 때 호출
  void _refreshPagination() {
    _pagingController.refresh();
  }

  List<Accommodation> _sortAndFilterHotels(List<Accommodation> hotels) {
    var filtered = hotels;

    if (_selectedRegion != null && _selectedRegion != '전체') {
      filtered = filtered.where((hotel) =>
        hotel.address.contains(_selectedRegion!)).toList();
    }

    switch (_sortBy) {
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanoljaColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),

          // 헤더 정보 + 필터 영역
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildIntroSection(),
                const SizedBox(height: 8),
                _buildFilterSection(),
              ],
            ),
          ),

          // 호텔 리스트 (무한 스크롤 + 스켈레톤 로딩)
          _buildInfiniteScrollHotelList(),
        ],
      ),
    );
  }

  /// 야놀자 스타일 화이트 좌측정렬 앱바
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: YanoljaColors.background,
      surfaceTintColor: YanoljaColors.background,
      shadowColor: YanoljaColors.shadow,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: YanoljaColors.textPrimary,
          size: 20,
        ),
        onPressed: () => context.pop(),
      ),
      title: const Text(
        '호텔·리조트',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: YanoljaColors.textPrimary,
          letterSpacing: -0.4,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.tune_rounded,
            color: YanoljaColors.textPrimary,
            size: 22,
          ),
          onPressed: _showFilterSheet,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  /// 상단 소개 영역 (플랫, 핑크 액센트)
  Widget _buildIntroSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: YanoljaColors.primaryLight,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: YanoljaColors.primary,
              borderRadius: BorderRadius.circular(YanoljaRadius.md),
            ),
            child: const Icon(
              Icons.hotel_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '엄선한 호텔·리조트',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '특가 혜택과 함께 편안한 하루를 즐겨보세요',
                  style: TextStyle(
                    fontSize: 13,
                    color: YanoljaColors.textSecondary,
                    height: 1.3,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 정렬 + 지역 필터 영역
  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      decoration: const BoxDecoration(
        color: YanoljaColors.background,
        border: Border(
          bottom: BorderSide(color: YanoljaColors.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 정렬 드롭다운
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
            child: Row(
              children: [
                const Text(
                  '지역',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: YanoljaColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: YanoljaColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                    border: Border.all(color: YanoljaColors.border, width: 1),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: YanoljaColors.textSecondary,
                      size: 18,
                    ),
                    elevation: 1,
                    isDense: true,
                    style: const TextStyle(
                      color: YanoljaColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    underline: const SizedBox(),
                    borderRadius: BorderRadius.circular(YanoljaRadius.md),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _updateSortBy(newValue);
                      }
                    },
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(value: 'rating', child: Text('평점순')),
                      DropdownMenuItem(value: 'price_low', child: Text('낮은 가격순')),
                      DropdownMenuItem(value: 'price_high', child: Text('높은 가격순')),
                      DropdownMenuItem(value: 'name', child: Text('이름순')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 지역 칩 (핑크 선택 상태)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              itemCount: _regions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final region = _regions[index];
                final isSelected =
                    (_selectedRegion ?? '전체') == region;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _updateSelectedRegion(region == '전체' ? null : region);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? YanoljaColors.primary
                          : YanoljaColors.background,
                      borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                      border: Border.all(
                        color: isSelected
                            ? YanoljaColors.primary
                            : YanoljaColors.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      region,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : YanoljaColors.textSecondary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// 무한 스크롤 호텔 리스트 (스켈레톤 로딩 포함)
  Widget _buildInfiniteScrollHotelList() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      sliver: PagedSliverList<int, Accommodation>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Accommodation>(
          // 일반 아이템 빌더 (절제된 페이드/슬라이드)
          itemBuilder: (context, accommodation, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 300),
              child: SlideAnimation(
                verticalOffset: 20.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildHotelCard(accommodation),
                  ),
                ),
              ),
            );
          },

          // 첫 페이지 로딩 (스켈레톤)
          firstPageProgressIndicatorBuilder: (context) =>
              _buildShimmerListLoading(),

          // 새 페이지 로딩 (하단 로딩)
          newPageProgressIndicatorBuilder: (context) => const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: YanoljaColors.primary,
                ),
              ),
            ),
          ),

          // 에러 상태
          firstPageErrorIndicatorBuilder: (context) =>
              _buildErrorState(_pagingController.error),

          // 새 페이지 에러
          newPageErrorIndicatorBuilder: (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '더 많은 호텔을 불러올 수 없습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: YanoljaColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPinkButton(
                  label: '다시 시도',
                  icon: Icons.refresh_rounded,
                  onPressed: () => _pagingController.retryLastFailedRequest(),
                ),
              ],
            ),
          ),

          // 빈 상태
          noItemsFoundIndicatorBuilder: (context) => _buildEmptyState(),

          // 더 이상 데이터가 없을 때
          noMoreItemsIndicatorBuilder: (context) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 40,
                  color: YanoljaColors.primary,
                ),
                const SizedBox(height: 10),
                const Text(
                  '모든 호텔을 확인했어요',
                  style: TextStyle(
                    fontSize: 15,
                    color: YanoljaColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '다른 지역이나 조건으로 검색해보세요',
                  style: TextStyle(
                    fontSize: 13,
                    color: YanoljaColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 스켈레톤 로딩 (리스트 형태)
  Widget _buildShimmerListLoading() {
    return Column(
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: YanoljaColors.surfaceAlt,
            highlightColor: const Color(0xFFFAFAFB),
            child: Container(
              height: 264,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 야놀자 플랫 호텔 카드
  Widget _buildHotelCard(Accommodation hotel) {
    final rate = YanoljaFormat.discountRate(hotel.id);
    final original = YanoljaFormat.originalPrice(hotel.price, rate);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/detail/${hotel.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: YanoljaColors.surface,
          borderRadius: BorderRadius.circular(YanoljaRadius.md),
          border: Border.all(color: YanoljaColors.border, width: 1),
          boxShadow: const [
            BoxShadow(
              color: YanoljaColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 + 배지 + 찜
            Stack(
              children: [
                Hero(
                  tag: 'hotel-${hotel.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(YanoljaRadius.md),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: hotel.imageUrls.isNotEmpty
                          ? hotel.imageUrls.first
                          : '',
                      height: 168,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 168,
                        color: YanoljaColors.surfaceAlt,
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 168,
                        color: YanoljaColors.surfaceAlt,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: YanoljaColors.textTertiary,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                // 좌상단 배지
                Positioned(
                  top: 12,
                  left: 12,
                  child: Row(
                    children: [
                      if (hotel.isNew) _buildBadge('NEW'),
                      if (hotel.isPopular) _buildBadge('인기'),
                    ],
                  ),
                ),
                // 우상단 찜 버튼
                Positioned(
                  top: 8,
                  right: 8,
                  child: _HotelHeartButton(accommodationId: hotel.id),
                ),
              ],
            ),
            // 콘텐츠
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: -0.3,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: YanoljaColors.textTertiary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          hotel.address,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: YanoljaColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  YanoljaRating(
                    rating: hotel.rating,
                    reviewCount: hotel.reviewCount,
                  ),
                  const SizedBox(height: 10),
                  // 가격 영역: 정가(취소선) + 핑크 할인율 + 굵은 현재가
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${YanoljaFormat.price(original)}원',
                        style: const TextStyle(
                          fontSize: 12,
                          color: YanoljaColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: YanoljaColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$rate%',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: YanoljaColors.primary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        YanoljaFormat.price(hotel.price),
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: YanoljaColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Text(
                        '원',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
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
    );
  }

  /// 작은 배지 (NEW / 인기)
  Widget _buildBadge(String text) {
    final isNew = text == 'NEW';
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isNew ? YanoljaColors.textPrimary : YanoljaColors.primary,
        borderRadius: BorderRadius.circular(YanoljaRadius.sm),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  /// 핑크 필 버튼
  Widget _buildPinkButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: YanoljaColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(YanoljaRadius.md),
        ),
      ),
    );
  }

  void _updateSortBy(String newSortBy) {
    setState(() {
      _sortBy = newSortBy;
    });
    _refreshPagination();
  }

  void _updateSelectedRegion(String? newRegion) {
    setState(() {
      _selectedRegion = newRegion;
    });
    _refreshPagination();
  }

  Widget _buildErrorState(Object? error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: YanoljaColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              '호텔 정보를 불러올 수 없습니다',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '잠시 후 다시 시도해 주세요',
              style: TextStyle(
                fontSize: 13,
                color: YanoljaColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildPinkButton(
              label: '다시 시도',
              icon: Icons.refresh_rounded,
              onPressed: () => _pagingController.refresh(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: YanoljaColors.primaryLight,
              ),
              child: const Icon(
                Icons.hotel_outlined,
                size: 48,
                color: YanoljaColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '조건에 맞는 호텔이 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '다른 지역이나 조건으로 검색해보세요',
              style: TextStyle(
                fontSize: 14,
                color: YanoljaColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildPinkButton(
              label: '필터 초기화',
              icon: Icons.refresh_rounded,
              onPressed: () {
                setState(() {
                  _selectedRegion = null;
                  _sortBy = 'rating';
                });
                _refreshPagination();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    // 필터 시트 진입점 (정렬/지역은 상단 영역에서 직접 조작)
  }
}

/// 카드 우상단 찜 버튼 (플랫, 핑크 액센트)
class _HotelHeartButton extends ConsumerWidget {
  final String accommodationId;

  const _HotelHeartButton({required this.accommodationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(savedProvider).contains(accommodationId);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(savedProvider.notifier).toggleSaved(accommodationId);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: YanoljaColors.shadow,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isSaved ? YanoljaColors.primary : YanoljaColors.textSecondary,
          size: 19,
        ),
      ),
    );
  }
}
