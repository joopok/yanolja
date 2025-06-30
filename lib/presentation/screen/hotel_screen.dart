import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🆕 햅틱 피드백용
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'; // 🆕 무한 스크롤용
import 'package:shimmer/shimmer.dart'; // 🆝 스켈레톤 로딩용
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/widget/accommodation_list_item.dart';

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

class _HotelScreenState extends ConsumerState<HotelScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // 🆕 무한 스크롤 컨트롤러
  final PagingController<int, Accommodation> _pagingController =
      PagingController(firstPageKey: 0);
  
  String _sortBy = 'rating';
  String? _selectedRegion;
  final List<String> _regions = ['전체', '서울', '부산', '제주', '강릉', '여수', '경주'];
  
  // 🆕 전체 호텔 데이터 캐시
  List<Accommodation> _allHotels = [];

  @override
  void initState() {
    super.initState();
    
    // 🎬 기본 애니메이션 컨트롤러
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    // 🚀 TikTok 스타일 슬라이딩 애니메이션 컨트롤러
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack, // TikTok 스타일의 탄성 곡선
    ));
    
    // 🎪 순차적 애니메이션 실행
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    
    // 🆕 페이지네이션 설정
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    _pagingController.dispose(); // 🆕 페이징 컨트롤러 정리
    super.dispose();
  }

  /// 🆕 페이지 단위로 데이터 로드
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

  /// 🆕 필터나 정렬이 변경될 때 호출
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

  Widget _getRegionIcon(String region) {
    switch (region) {
      case '전체':
        return const Icon(Icons.public, size: 16);
      case '서울':
        return const Icon(Icons.location_city, size: 16);
      case '부산':
        return const Icon(Icons.waves, size: 16);
      case '제주':
        return const Icon(Icons.landscape, size: 16);
      case '강릉':
        return const Icon(Icons.beach_access, size: 16);
      case '여수':
        return const Icon(Icons.sailing, size: 16);
      case '경주':
        return const Icon(Icons.account_balance, size: 16);
      default:
        return const Icon(Icons.place, size: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hotelAsync = ref.watch(hotelAccommodationsProvider);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(), // iOS 스타일 바운스 효과
        slivers: [
          _buildTikTokStyleSliverAppBar(theme),
          
          // 🎭 TikTok 스타일 슬라이딩 콘텐츠
          SliverOpacity(
            opacity: 0.98,
            sliver: SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildInstagramStoryStyleInfo(theme),
                      const SizedBox(height: 24),
                      _buildTikTokStyleFilterSection(theme),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // 🚀 호텔 리스트 (무한 스크롤 + 스켈레톤 로딩)
          _buildInfiniteScrollHotelList(theme),
        ],
      ),
    );
  }

  /// 🎬 TikTok 스타일 SliverAppBar (최신 Material 3)
  Widget _buildTikTokStyleSliverAppBar(ThemeData theme) {
    return SliverAppBar.medium( // Context7 최신 기능
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: theme.colorScheme.onSurface,
        ),
        onPressed: () => context.pop(),
      ),
      title: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(-20 * (1 - value), 0),
            child: Opacity(
              opacity: value,
              child: Text(
                '프리미엄 호텔',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          );
        },
      ),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      actions: [
        // Instagram 스타일 필터 버튼
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.tune_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            onPressed: _showTikTokStyleFilterSheet,
          ),
        ),
      ],
    );
  }

  Widget _buildInstagramStoryStyleInfo(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 섹션
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1),
                      theme.colorScheme.primary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.hotel_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '프리미엄 호텔',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '럭셔리한 경험과 완벽한 서비스',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // 특징 카드들
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.star_rounded,
                  title: '5성급',
                  subtitle: '최고급 서비스',
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.room_service_rounded,
                  title: '24시간',
                  subtitle: '컨시어지',
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  icon: Icons.spa_rounded,
                  title: '스파',
                  subtitle: '프리미엄 시설',
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTikTokStyleFilterSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '지역 선택',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _sortBy,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  elevation: 0,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _sortBy = newValue;
                      });
                    }
                  },
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem(
                      value: 'rating',
                      child: Text('평점순'),
                    ),
                    DropdownMenuItem(
                      value: 'price_low',
                      child: Text('낮은 가격순'),
                    ),
                    DropdownMenuItem(
                      value: 'price_high',
                      child: Text('높은 가격순'),
                    ),
                    DropdownMenuItem(
                      value: 'name',
                      child: Text('이름순'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Modern Material 3 SegmentedButton for region selection
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SegmentedButton<String>(
                segments: _regions.map((region) => ButtonSegment<String>(
                  value: region,
                  label: Text(region),
                  icon: _getRegionIcon(region),
                )).toList(),
                selected: {_selectedRegion ?? '전체'},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    final selected = newSelection.first;
                    _selectedRegion = selected == '전체' ? null : selected;
                  });
                },
                multiSelectionEnabled: false,
                style: theme.segmentedButtonTheme.style?.copyWith(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  textStyle: WidgetStateProperty.all(
                    theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🚀 무한 스크롤 호텔 리스트 (스켈레톤 로딩 포함)
  Widget _buildInfiniteScrollHotelList(ThemeData theme) {
    return SliverFillRemaining(
      child: PagedListView<int, Accommodation>(
        pagingController: _pagingController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        builderDelegate: PagedChildBuilderDelegate<Accommodation>(
          // 🎯 일반 아이템 빌더
          itemBuilder: (context, accommodation, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 475),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: ScaleAnimation(
                    scale: 0.97,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: _buildModernHotelCard(accommodation, theme),
                    ),
                  ),
                ),
              ),
            );
          },
          
          // 🎯 첫 페이지 로딩 (스켈레톤)
          firstPageProgressIndicatorBuilder: (context) => 
              _buildShimmerListLoading(),
          
          // 🎯 새 페이지 로딩 (하단 로딩)
          newPageProgressIndicatorBuilder: (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: theme.colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // 🎯 에러 상태
          firstPageErrorIndicatorBuilder: (context) =>
              _buildTikTokStyleErrorState(theme, _pagingController.error),
          
          // 🎯 새 페이지 에러
          newPageErrorIndicatorBuilder: (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '더 많은 호텔을 불러올 수 없습니다',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _pagingController.retryLastFailedRequest(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('다시 시도'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 🎯 빈 상태
          noItemsFoundIndicatorBuilder: (context) =>
              _buildInstagramStyleEmptyState(theme),
              
          // 🎯 더 이상 데이터가 없을 때
          noMoreItemsIndicatorBuilder: (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 48,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(height: 12),
                Text(
                  '모든 호텔을 확인했습니다',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '다른 지역이나 조건으로 검색해보세요',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 스켈레톤 로딩 (리스트 형태)
  Widget _buildShimmerListLoading() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 5, // 5개의 스켈레톤 카드
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🎯 현대적인 호텔 카드 (Instagram/Airbnb 스타일)
  Widget _buildModernHotelCard(Accommodation hotel, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); // 햅틱 피드백
        context.push('/detail/${hotel.id}');
      },
      child: Hero(
        tag: 'hotel-${hotel.id}',
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: AccommodationListItem(accommodation: hotel),
        ),
      ),
    );
  }

  /// 🔧 정렬 및 필터링 메서드 수정 (페이지네이션 새로고침 추가)
  void _updateSortBy(String newSortBy) {
    setState(() {
      _sortBy = newSortBy;
    });
    _refreshPagination(); // 🆕 페이지네이션 새로고침
  }

  void _updateSelectedRegion(String? newRegion) {
    setState(() {
      _selectedRegion = newRegion;
    });
    _refreshPagination(); // 🆕 페이지네이션 새로고침
  }

  Widget _buildTikTokStyleErrorState(ThemeData theme, Object error) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '호텔 정보를 불러올 수 없습니다',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstagramStyleEmptyState(ThemeData theme) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.hotel_outlined,
                size: 72,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '조건에 맞는 호텔이 없습니다',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '다른 지역이나 조건으로 검색해보세요',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedRegion = null;
                  _sortBy = 'rating';
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('필터 초기화'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTikTokStyleFilterSheet() {
    // Implementation of _showTikTokStyleFilterSheet method
  }
}