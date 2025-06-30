import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/widget/neumorphism_components.dart';

/// 🏠 **네오모피즘 홈 화면**
/// 부드러운 그림자와 입체감이 특징인 현대적 디자인
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  int _currentCarouselIndex = 0;
  String _selectedSortOption = '추천순';
  
  @override
  void initState() {
    super.initState();
    
    // 🎭 페이드 인 애니메이션
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accommodations = ref.watch(accommodationListProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 🎨 네오모피즘 앱바
            _buildNeumorphismAppBar(),
            
            // 🔍 검색 바
            SliverToBoxAdapter(
              child: _buildNeumorphismSearchBar(),
            ),
            
            // 🎠 배너 캐러셀
            SliverToBoxAdapter(
              child: _buildNeumorphismBannerCarousel(),
            ),
            
            // 🏨 퀵 메뉴
            SliverToBoxAdapter(
              child: _buildNeumorphismQuickMenu(),
            ),
            
            // 🏷️ 카테고리 칩들
            SliverToBoxAdapter(
              child: _buildNeumorphismCategoryChips(),
            ),
            
            // 📊 스티키 헤더
            _buildNeumorphismStickyHeader(),
            
            // 🏠 숙소 리스트
            accommodations.when(
              data: (data) => _buildNeumorphismAccommodationGrid(data),
              loading: () => _buildNeumorphismShimmerLoading(),
              error: (error, _) => _buildNeumorphismErrorView(error),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 **네오모피즘 앱바**
  Widget _buildNeumorphismAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Row(
            children: [
              // 🌟 로고 및 인사말
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '안녕하세요! 👋',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '어디로 떠나볼까요?',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 🔔 알림 버튼
              NeumorphismIconButton(
                icon: Icons.notifications_none_rounded,
                size: 48,
                iconSize: 24,
                onTap: () => _showNeumorphismSnackBar('알림 기능 준비중입니다'),
              ),
              
              const SizedBox(width: 12),
              
              // 👤 프로필 버튼
              NeumorphismIconButton(
                icon: Icons.person_outline_rounded,
                size: 48,
                iconSize: 24,
                onTap: () => context.push('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔍 **네오모피즘 검색 바**
  Widget _buildNeumorphismSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: NeumorphismTextField(
        hintText: '어디로 여행을 떠나시나요?',
        prefixIcon: Icons.search_rounded,
        suffixIcon: Icons.tune_rounded,
        readOnly: true,
        onTap: () => context.push('/search'),
        onSuffixIconTap: () => _showNeumorphismSortBottomSheet(),
      ),
    );
  }

  /// 🎠 **네오모피즘 배너 캐러셀**
  Widget _buildNeumorphismBannerCarousel() {
    final bannerData = [
      {
        'title': '🏨 프리미엄 호텔',
        'subtitle': '최고급 호텔에서 특별한 하루를',
        'image': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'accommodationId': '1',
      },
      {
        'title': '🏡 아늑한 펜션',
        'subtitle': '자연 속에서 힐링하는 시간',
        'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
        'accommodationId': '2',
      },
      {
        'title': '🏖️ 리조트 패키지',
        'subtitle': '바다가 보이는 특별한 휴양지',
        'image': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
        'accommodationId': '3',
      },
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          // 🎠 캐러셀
          SizedBox(
            height: 200,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                viewportFraction: 0.85,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() => _currentCarouselIndex = index);
                },
              ),
              items: bannerData.map((banner) {
                return _buildNeumorphismBannerCard(banner);
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 📍 페이지 인디케이터
          AnimatedSmoothIndicator(
            activeIndex: _currentCarouselIndex,
            count: bannerData.length,
            effect: ExpandingDotsEffect(
              dotWidth: 8,
              dotHeight: 8,
              spacing: 8,
              activeDotColor: Theme.of(context).colorScheme.primary,
              dotColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 **네오모피즘 배너 카드**
  Widget _buildNeumorphismBannerCard(Map<String, String> banner) {
    return NeumorphismCard(
      borderRadius: 24,
      padding: EdgeInsets.zero,
      onTap: () {
        HapticFeedback.lightImpact();
        final accommodationId = banner['accommodationId'];
        if (accommodationId != null) {
          context.push('/detail/$accommodationId');
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🖼️ 배경 이미지
            CachedNetworkImage(
              imageUrl: banner['image']!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            
            // 🌅 그라데이션 오버레이
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            
            // 📝 텍스트 콘텐츠
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      banner['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner['subtitle']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🏨 **네오모피즘 퀵 메뉴**
  Widget _buildNeumorphismQuickMenu() {
    final quickMenuItems = [
      {
        'icon': Icons.hotel_rounded,
        'label': '호텔',
        'route': '/hotel',
        'color': const Color(0xFF6B7280), // 모던 그레이
        'emoji': '🏨'
      },
      {
        'icon': Icons.cottage_rounded,
        'label': '펜션',
        'route': '/pension',
        'color': const Color(0xFF9CA3AF), // 라이트 그레이
        'emoji': '🏡'
      },
      {
        'icon': Icons.pool_rounded,
        'label': '리조트',
        'route': '/resort',
        'color': const Color(0xFF374151), // 다크 그레이
        'emoji': '🏖️'
      },
      {
        'icon': Icons.temple_buddhist_rounded,
        'label': '한옥',
        'route': '/hanok',
        'color': const Color(0xFF4B5563), // 미드 그레이
        'emoji': '🏛️'
      },
      {
        'icon': Icons.restaurant_rounded,
        'label': '맛집',
        'route': '/masgib',
        'color': const Color(0xFF6C63FF), // T membership 보라색
        'emoji': '🍽️'
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: NeumorphismCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 섹션 헤더
            Row(
              children: [
                NeumorphismIconButton(
                  icon: Icons.explore_rounded,
                  size: 40,
                  iconSize: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  iconColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '어디로 갈까요?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '다양한 숙소 타입을 탐험해보세요',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 🏨 퀵 메뉴 그리드
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: quickMenuItems.length,
              itemBuilder: (context, index) {
                final item = quickMenuItems[index];
                return _buildNeumorphismQuickMenuItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 **네오모피즘 퀵 메뉴 아이템**
  Widget _buildNeumorphismQuickMenuItem(Map<String, dynamic> item) {
    return NeumorphismCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(item['route']);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🎨 아이콘 컨테이너
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (item['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              boxShadow: NeumorphismHelper.softShadow,
            ),
            child: Center(
              child: Text(
                item['emoji'],
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 📝 라벨
          Text(
            item['label'],
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 🏷️ **네오모피즘 카테고리 칩들**
  Widget _buildNeumorphismCategoryChips() {
    final categories = ['전체', '신규', '인기', '추천', '특가', '럭셔리'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = index == 0; // 첫 번째를 선택상태로
          
          return Container(
            margin: EdgeInsets.only(right: index < categories.length - 1 ? 12 : 0),
            child: NeumorphismChip(
              label: category,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.lightImpact();
                _showNeumorphismSnackBar('$category 필터 적용됨');
              },
            ),
          );
        },
      ),
    );
  }

  /// 📊 **네오모피즘 스티키 헤더**
  Widget _buildNeumorphismStickyHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _NeumorphismStickyHeaderDelegate(
        minHeight: 80,
        maxHeight: 80,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: NeumorphismHelper.softShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '추천 숙소',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '243개의 숙소',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 🎛️ 정렬 버튼
              NeumorphismButton(
                text: _selectedSortOption,
                icon: Icons.tune_rounded,
                onTap: () => _showNeumorphismSortBottomSheet(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fontSize: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🏠 **네오모피즘 숙소 그리드**
  Widget _buildNeumorphismAccommodationGrid(List<Accommodation> accommodations) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childCount: accommodations.length,
        itemBuilder: (context, index) {
          final accommodation = accommodations[index];
          return _buildNeumorphismAccommodationCard(accommodation);
        },
      ),
    );
  }

  /// 🏨 **네오모피즘 숙소 카드**
  Widget _buildNeumorphismAccommodationCard(Accommodation accommodation) {
    return NeumorphismCard(
      padding: EdgeInsets.zero,
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/detail/${accommodation.id}');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ 이미지 섹션
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: accommodation.imageUrls.isNotEmpty 
                      ? accommodation.imageUrls.first 
                      : 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 140,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
                
                // 🌟 인기 뱃지
                if (accommodation.isPopular)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: NeumorphismBadge(
                      text: '인기',
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                
                // ⭐ 평점 뱃지
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: NeumorphismHelper.softShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          accommodation.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 📝 정보 섹션
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accommodation.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  accommodation.address,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Text(
                      '₩${accommodation.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      '/박',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✨ **네오모피즘 시머 로딩**
  Widget _buildNeumorphismShimmerLoading() {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childCount: 8,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: NeumorphismCard(
              padding: EdgeInsets.zero,
              child: Container(
                height: index.isEven ? 260 : 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ❌ **네오모피즘 에러 뷰**
  Widget _buildNeumorphismErrorView(Object error) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: NeumorphismCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              NeumorphismIconButton(
                icon: Icons.error_outline_rounded,
                size: 64,
                iconSize: 32,
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                iconColor: Colors.red,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                '데이터를 불러올 수 없습니다',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              NeumorphismButton(
                text: '다시 시도',
                icon: Icons.refresh_rounded,
                onTap: () => ref.invalidate(accommodationListProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎯 **정렬 옵션 바텀시트**
  void _showNeumorphismSortBottomSheet() {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: NeumorphismHelper.elevatedShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🎛️ 드래그 핸들
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 📌 헤더
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '정렬 옵션',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // 📋 정렬 옵션들
            ...['추천순', '낮은 가격순', '높은 가격순', '평점순', '리뷰순'].map((option) {
              return ListTile(
                title: Text(option),
                trailing: _selectedSortOption == option
                    ? Icon(
                        Icons.check_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  setState(() => _selectedSortOption = option);
                  Navigator.pop(context);
                  _showNeumorphismSnackBar('$option으로 정렬됨');
                },
              );
            }).toList(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 🍿 **네오모피즘 스낵바**
  void _showNeumorphismSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}

/// 📊 **네오모피즘 스티키 헤더 델리게이트**
class _NeumorphismStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _NeumorphismStickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

