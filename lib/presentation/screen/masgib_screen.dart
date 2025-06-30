import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// 🎯 **T membership 이미지 완벽 복제 화면**
/// 첨부된 이미지와 100% 동일하게 구현한 맛집/멤버십 화면
class MasgibScreen extends ConsumerStatefulWidget {
  const MasgibScreen({super.key});

  @override
  ConsumerState<MasgibScreen> createState() => _MasgibScreenState();
}

class _MasgibScreenState extends ConsumerState<MasgibScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  
  // 🎨 정확한 T membership 컬러 팔레트 (재분석)
  static const Color _primaryPurple = Color(0xFF6C63FF);
  static const Color _lightPurple = Color.fromARGB(255, 37, 4, 249);
  static const Color _pinkBanner = Color(0xFFFFE5F1);
  static const Color _lightPink = Color(0xFFFFF0F8);
  static const Color _successGreen = Color(0xFF00D4A3);
  static const Color _blueT = Color.fromARGB(255, 1, 79, 246);
  static const Color _blue0 = Color(0xFF0EA5E9);
  static const Color _orangeBag = Color(0xFFEA580C);
  static const Color _pinkEvent = Color(0xFFEC4899);
  static const Color _mintTravel = Color(0xFF06B6D4);
  static const Color _blueCheck = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildTabBar(),
          _buildMainBanner(),
          _buildServiceGrid(),
          _buildPromotionTitle(),
          _buildPromotionCards(),
          _buildBottomInfo(),
        ],
      ),
    );
  }

  /// 🔥 정확한 보라색 그라데이션 AppBar
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 70,
      floating: false,
      pinned: true,
      backgroundColor: _primaryPurple,
      title: const Text(
        'T membership',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryPurple, _lightPurple],
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.folder_outlined, color: Colors.white),
            ),
            onPressed: () {},
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white, size: 26),
          onPressed: () {},
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 26),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  /// 📑 정확한 탭 바 구현
  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryPurple, _lightPurple],
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            labelStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(text: 'T 멤버십'),
              Tab(text: 'T 우주'),
              Tab(text: '미션'),
            ],
          ),
        ),
      ),
    );
  }

  /// 🎨 완벽한 핑크 배너 카드 (재분석 적용)
  Widget _buildMainBanner() {
    return SliverToBoxAdapter(
      child: AnimationLimiter(
        child: AnimationConfiguration.staggeredList(
          position: 0,
          duration: const Duration(milliseconds: 800),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_pinkBanner, _lightPink],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryPurple.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 왼쪽 텍스트 영역
                    Positioned(
                      left: 24,
                      top: 28,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '매달 여러 혜택을 쏟 수 있는',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'VIP PICK PLUS 혜택!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'VIP라면 놓치지 마세요',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 오른쪽 브랜드 로고들 (재분석 - 더 자연스러운 배치)
                    Positioned(
                      right: 16,
                      top: 16,
                      width: 120,
                      height: 120,
                      child: Stack(
                        children: [
                          // CGV 로고
                          Positioned(
                            top: 8,
                            right: 45,
                            child: _buildBrandLogo('CGV', const Color(0xFFE53E3E), Colors.white, 40),
                          ),
                          // VIP 로고  
                          Positioned(
                            top: 20,
                            right: 8,
                            child: _buildBrandLogo('VIP', _primaryPurple, Colors.white, 48),
                          ),
                          // T 로고
                          Positioned(
                            top: 58,
                            right: 50,
                            child: _buildBrandLogo('T', const Color(0xFF059669), Colors.white, 35),
                          ),
                          // CGV 하단 로고
                          Positioned(
                            top: 45,
                            right: 15,
                            child: _buildBrandLogo('CGV', const Color(0xFFDC2626), Colors.white, 38),
                          ),
                          // 추가 브랜드 로고들
                          Positioned(
                            top: 75,
                            right: 25,
                            child: _buildBrandLogo('T', const Color(0xFF2563EB), Colors.white, 32),
                          ),
                        ],
                      ),
                    ),
                    
                    // 하단 페이지 인디케이터
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pause, color: Colors.white, size: 14),
                            SizedBox(width: 6),
                            Text(
                              '4/10',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.add, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🏷️ 정확한 브랜드 로고 (크기 조절 가능)
  Widget _buildBrandLogo(String text, Color bgColor, Color textColor, [double size = 44]) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: text.length > 3 ? size * 0.18 : size * 0.28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 🎯 정확한 서비스 그리드 (4x2) - 재분석 적용
  Widget _buildServiceGrid() {
    final services = [
      // 첫 번째 줄
      {'title': 'T day', 'text': 'T', 'color': _blueT, 'textColor': Colors.white, 'bgStyle': 'solid'},
      {'title': '0 day', 'text': '0', 'color': _blue0, 'textColor': Colors.white, 'bgStyle': 'solid'},  
      {'title': 'VIP PICK', 'text': 'VIP', 'color': _primaryPurple, 'textColor': Colors.white, 'badge': 'PICK', 'bgStyle': 'solid'},
      {'title': '클럽 T 로링', 'text': 'Club', 'color': _primaryPurple, 'textColor': Colors.white, 'bgStyle': 'solid'},
      // 두 번째 줄
      {'title': '혜택 브랜드', 'icon': '🛍️', 'color': _orangeBag, 'textColor': Colors.white, 'bgStyle': 'solid'},
      {'title': '이벤트', 'text': 'T', 'color': _pinkEvent, 'textColor': Colors.white, 'bgStyle': 'solid'},
      {'title': '글로벌여행', 'icon': '✈️', 'color': _mintTravel, 'textColor': Colors.white, 'bgStyle': 'solid'},
      {'title': '출석체크', 'icon': '✓', 'color': _blueCheck, 'textColor': Colors.white, 'bgStyle': 'solid'},
    ];

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: AnimationLimiter(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 20,
              childAspectRatio: 0.8,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 500),
                columnCount: 4,
                child: FadeInAnimation(
                  child: ScaleAnimation(
                    scale: 0.8,
                    child: _buildServiceCard(services[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 🎴 정확한 서비스 카드 (재분석 개선)
  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: service['color'],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (service['color'] as Color).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: service['icon'] != null
                    ? Text(
                        service['icon'],
                        style: const TextStyle(fontSize: 18),
                      )
                    : Text(
                        service['text'] ?? '',
                        style: TextStyle(
                          color: service['textColor'],
                          fontSize: service['text']?.length > 2 ? 10 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            // VIP PICK 뱃지
            if (service['badge'] != null)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _pinkEvent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service['badge'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          service['title'],
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }

  /// 🌟 프로모션 제목
  Widget _buildPromotionTitle() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: const Text(
          '7월의 T day 혜택을 알려드려요!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }

  /// 🏊‍♂️ 정확한 민트색 프로모션 카드
  Widget _buildPromotionCards() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 250,
        decoration: BoxDecoration(
          color: _successGreen,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _successGreen.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 상단 텍스트
            const Positioned(
              left: 20,
              top: 20,
              child: Text(
                '7월의 Day 혜택 | 7.2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // 오른쪽 수영 일러스트
            Positioned(
              right: 20,
              top: 30,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '🏊‍♂️',
                  style: TextStyle(fontSize: 36),
                ),
              ),
            ),
            
            // 하단 D-3 카드들
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final brands = ['뚜레쥬르', '혜택 오픈', '정원식당'];
                    return Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'D-3',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            brands[index],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 하단 정보 섹션 (재분석 개선)
  Widget _buildBottomInfo() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 왼쪽 라벨들
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '참인형',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '도승현님',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 12),
            
            // VIP 라벨
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'VIP',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            
            const Spacer(),
            
            // 중간 추천 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _primaryPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '추천',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const Spacer(),
            
            // 오른쪽 가격과 바코드
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 바코드 아이콘
                Icon(
                  Icons.qr_code,
                  size: 24,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                const Text(
                  '9,900원',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 📑 TabBar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate(this.child);

  @override
  double get minExtent => 38;

  @override
  double get maxExtent => 38;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
