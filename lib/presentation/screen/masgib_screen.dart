import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_bottom_nav.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

/// 🍽️ 맛집 화면 — NOL 블루 플랫 디자인
/// 보라색/블루 그라데이션 및 멤버십 흔적을 제거하고
/// 야놀자 디자인 언어(화이트 배경 · NOL 블루 포인트 · 플랫 카드)로 재구성했습니다.
class MasgibScreen extends ConsumerStatefulWidget {
  const MasgibScreen({super.key});

  @override
  ConsumerState<MasgibScreen> createState() => _MasgibScreenState();
}

class _MasgibScreenState extends ConsumerState<MasgibScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  /// 현재 선택된 탭(추천/근처/인기). 탭 전환 시 아래 맛집 섹션 콘텐츠가 바뀐다.
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.index != _tabIndex) {
      setState(() => _tabIndex = _tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanoljaColors.background,
      bottomNavigationBar: const YanoljaBottomNav(selectedBranchIndex: 2),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildTabBar(),
          _buildMainBanner(),
          _buildSectionGap(),
          _buildServiceGrid(),
          _buildSectionDivider(),
          _buildRestaurantSection(),
          _buildSectionDivider(),
          _buildPromotionTitle(),
          _buildPromotionCard(),
          _buildBottomInfo(),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  /// 화이트 좌측정렬 AppBar (테마 일관)
  Widget _buildAppBar() {
    return YanoljaSliverAppBar.sub(
      title: '맛집',
      fallbackRoute: '/nearby',
      actions: [
        IconButton(
          icon: const Icon(
            Icons.search_rounded,
            color: YanoljaColors.textPrimary,
            size: 24,
          ),
          onPressed: () => context.go('/search'),
        ),
        IconButton(
          icon: const Icon(
            Icons.bookmark_border_rounded,
            color: YanoljaColors.textPrimary,
            size: 24,
          ),
          onPressed: () => context.go('/saved'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// NOL 블루 인디케이터 탭바 (화이트 배경 + 헤어라인)
  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        Container(
          decoration: const BoxDecoration(
            color: YanoljaColors.background,
            border: Border(
              bottom: BorderSide(color: YanoljaColors.border, width: 1),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: YanoljaColors.primary,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: YanoljaColors.textPrimary,
            unselectedLabelColor: YanoljaColors.textTertiary,
            labelPadding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.m),
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
            ),
            tabs: const [
              Tab(text: '추천 맛집'),
              Tab(text: '근처 맛집'),
              Tab(text: '인기 메뉴'),
            ],
          ),
        ),
      ),
    );
  }

  /// 메인 프로모션 배너 — 연블루(primaryLight 틴트) 플랫 카드
  Widget _buildMainBanner() {
    return SliverToBoxAdapter(
      child: YanoljaEntrance(
        delay: YanoljaMotion.stagger(0),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          height: 160,
          decoration: BoxDecoration(
            color: YanoljaColors.primaryLight,
            borderRadius: BorderRadius.circular(YanoljaRadius.lg),
            border: Border.all(color: YanoljaColors.border),
            boxShadow: const [
              BoxShadow(
                color: YanoljaColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 22,
                top: 26,
                right: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: YanoljaSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: YanoljaColors.primary,
                        borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                      ),
                      child: const Text(
                        '이달의 맛집 혜택',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '미식가를 위한\n특별 할인 혜택',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: YanoljaColors.textPrimary,
                        height: 1.25,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '엄선한 맛집을 더 저렴하게',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: YanoljaColors.textSecondary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),

              // 오른쪽 일러스트 (절제된 단일 아이콘 원형)
              Positioned(
                right: 24,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: YanoljaColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: YanoljaColors.border),
                    ),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      color: YanoljaColors.primary,
                      size: 40,
                    ),
                  ),
                ),
              ),

              // 맛집 PICK 정적 태그 (플랫 NOL 블루 칩)
              Positioned(
                bottom: 14,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: YanoljaColors.surface,
                    borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                    border: Border.all(color: YanoljaColors.border),
                  ),
                  child: const Text(
                    '맛집 PICK',
                    style: TextStyle(
                      color: YanoljaColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionGap() {
    return const SliverToBoxAdapter(
      child: SizedBox(height: 4),
    );
  }

  /// 카테고리 그리드 (4x2) — 플랫 NOL 블루(연블루) 틴트 아이콘
  Widget _buildServiceGrid() {
    final services = [
      {'title': '한식', 'icon': Icons.rice_bowl_rounded},
      {'title': '카페·디저트', 'icon': Icons.local_cafe_rounded},
      {'title': '고기·구이', 'icon': Icons.outdoor_grill_rounded},
      {'title': '횟집·해산물', 'icon': Icons.set_meal_rounded},
      {'title': '양식·파스타', 'icon': Icons.dinner_dining_rounded},
      {'title': '분식', 'icon': Icons.ramen_dining_rounded},
      {'title': '술집·이자카야', 'icon': Icons.wine_bar_rounded},
      {'title': '전체보기', 'icon': Icons.grid_view_rounded},
    ];

    return SliverToBoxAdapter(
      child: YanoljaEntrance(
        delay: YanoljaMotion.stagger(1),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 16,
              childAspectRatio: 0.74,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return _buildServiceCard(services[index]);
            },
          ),
        ),
      ),
    );
  }

  /// 카테고리 카드 — 연블루(primaryLight) 배경 + NOL 블루 아이콘 (플랫)
  Widget _buildServiceCard(Map<String, dynamic> service) {
    final title = service['title'] as String;
    return YanoljaPressable(
      onTap: () {
        HapticFeedback.lightImpact();
        if (title == '전체보기') {
          context.go('/search');
        } else {
          YanoljaToast.show(context, '$title 맛집을 모아볼게요',
              icon: Icons.restaurant_rounded);
          context.go('/search');
        }
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: YanoljaColors.primaryLight,
              borderRadius: BorderRadius.circular(YanoljaRadius.lg),
            ),
            child: Icon(
              service['icon'] as IconData,
              color: YanoljaColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: YanoljaColors.textPrimary,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 탭(추천/근처/인기 메뉴)에 따라 콘텐츠가 실제로 바뀌는 맛집 섹션.
  Widget _buildRestaurantSection() {
    final tab = _restaurantTabs[_tabIndex];
    return SliverToBoxAdapter(
      child: YanoljaEntrance(
        // 탭 전환 시 키가 바뀌어 등장 애니메이션이 다시 재생된다.
        key: ValueKey(_tabIndex),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YanoljaSectionHeader(title: tab.title, subtitle: tab.subtitle),
            ...List.generate(tab.items.length, (i) {
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  i == tab.items.length - 1 ? 4 : 12,
                ),
                child: _buildRestaurantCard(tab.items[i]),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(_MasgibPlace place) {
    return YanoljaPressable(
      onTap: () {
        HapticFeedback.lightImpact();
        YanoljaToast.show(context, '${place.name} 상세는 준비 중이에요',
            icon: Icons.restaurant_menu_rounded);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: YanoljaColors.surface,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: YanoljaColors.primaryLight,
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: Icon(place.icon, color: YanoljaColors.primary, size: 28),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${place.area} · ${place.menu}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: YanoljaColors.textSecondary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  YanoljaRating(
                    rating: place.rating,
                    reviewCount: place.reviews,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: YanoljaColors.sale.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(YanoljaRadius.sm),
              ),
              child: Text(
                place.badge,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: YanoljaColors.sale,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 섹션 구분 띠 (surfaceAlt 8px)
  Widget _buildSectionDivider() {
    return const SliverToBoxAdapter(
      child: SizedBox(
        height: 8,
        child: ColoredBox(color: YanoljaColors.surfaceAlt),
      ),
    );
  }

  /// 프로모션 섹션 제목
  Widget _buildPromotionTitle() {
    return const SliverToBoxAdapter(
      child: YanoljaSectionHeader(
        title: '이번 달 맛집 혜택을 알려드려요',
        subtitle: '놓치면 아쉬운 한정 특가',
      ),
    );
  }

  /// 프로모션 카드 — 화이트 카드 + 헤어라인, NOL 블루 포인트
  Widget _buildPromotionCard() {
    final items = [
      {'tag': 'D-3', 'name': '뚜레쥬르', 'menu': '베이커리 10% 할인'},
      {'tag': 'D-5', 'name': '본가설렁탕', 'menu': '식사권 5천원 할인'},
      {'tag': 'D-7', 'name': '정원식당', 'menu': '디저트 무료 제공'},
    ];

    return SliverToBoxAdapter(
      child: YanoljaEntrance(
        delay: YanoljaMotion.stagger(2),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: YanoljaColors.surface,
            borderRadius: BorderRadius.circular(YanoljaRadius.lg),
            border: Border.all(color: YanoljaColors.border),
            boxShadow: const [
              BoxShadow(
                color: YanoljaColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: YanoljaColors.primaryLight,
                      borderRadius: BorderRadius.circular(YanoljaRadius.md),
                    ),
                    child: const Icon(
                      Icons.local_offer_rounded,
                      color: YanoljaColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7월의 맛집 혜택',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: YanoljaColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '매주 새로운 맛집이 오픈돼요',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: YanoljaColors.textSecondary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(items.length, (index) {
                final item = items[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == items.length - 1 ? 0 : 12,
                  ),
                  child: YanoljaPressable(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/service/deals');
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          padding: const EdgeInsets.symmetric(vertical: YanoljaSpacing.s),
                          decoration: BoxDecoration(
                            color: YanoljaColors.primaryLight,
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.sm),
                          ),
                          child: Text(
                            item['tag']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: YanoljaColors.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: YanoljaColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['menu']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: YanoljaColors.textSecondary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: YanoljaColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// 하단 멤버 정보 — 화이트 카드 + NOL 블루 포인트 (플랫)
  Widget _buildBottomInfo() {
    return SliverToBoxAdapter(
      child: YanoljaEntrance(
        delay: YanoljaMotion.stagger(3),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: YanoljaColors.surface,
            borderRadius: BorderRadius.circular(YanoljaRadius.lg),
            border: Border.all(color: YanoljaColors.border),
            boxShadow: const [
              BoxShadow(
                color: YanoljaColors.shadow,
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // 왼쪽 사용자 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: YanoljaSpacing.s,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: YanoljaColors.primary,
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.sm),
                          ),
                          child: const Text(
                            'VIP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '회원님',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: YanoljaColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '맛집 쿠폰 3장 보유 중',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: YanoljaColors.textSecondary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),

              // 오른쪽 쿠폰 버튼 (NOL 블루 필 버튼)
              YanoljaPressable(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/service/coupons');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: YanoljaColors.primary,
                    borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                  ),
                  child: const Text(
                    '쿠폰함',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 탭별 맛집 콘텐츠 데이터
class _MasgibTab {
  final String title;
  final String subtitle;
  final List<_MasgibPlace> items;

  const _MasgibTab({
    required this.title,
    required this.subtitle,
    required this.items,
  });
}

class _MasgibPlace {
  final String name;
  final String area;
  final String menu;
  final double rating;
  final int reviews;
  final String badge;
  final IconData icon;

  const _MasgibPlace({
    required this.name,
    required this.area,
    required this.menu,
    required this.rating,
    required this.reviews,
    required this.badge,
    required this.icon,
  });
}

const List<_MasgibTab> _restaurantTabs = [
  _MasgibTab(
    title: '추천 맛집',
    subtitle: 'NOL 에디터가 직접 다녀온 곳',
    items: [
      _MasgibPlace(
        name: '광장시장 손칼국수',
        area: '서울 종로',
        menu: '손칼국수 · 빈대떡',
        rating: 4.8,
        reviews: 2310,
        badge: '15%',
        icon: Icons.ramen_dining_rounded,
      ),
      _MasgibPlace(
        name: '해운대 암소갈비집',
        area: '부산 해운대',
        menu: '한우 생갈비',
        rating: 4.7,
        reviews: 1894,
        badge: '10%',
        icon: Icons.outdoor_grill_rounded,
      ),
      _MasgibPlace(
        name: '제주 고등어쌈밥',
        area: '제주 서귀포',
        menu: '고등어구이 정식',
        rating: 4.9,
        reviews: 1450,
        badge: '12%',
        icon: Icons.set_meal_rounded,
      ),
    ],
  ),
  _MasgibTab(
    title: '근처 맛집',
    subtitle: '지금 위치에서 가까운 순',
    items: [
      _MasgibPlace(
        name: '연남동 파스타바',
        area: '도보 4분',
        menu: '관자 알리오올리오',
        rating: 4.6,
        reviews: 982,
        badge: '8%',
        icon: Icons.dinner_dining_rounded,
      ),
      _MasgibPlace(
        name: '골목 수제버거',
        area: '도보 7분',
        menu: '더블 치즈버거',
        rating: 4.5,
        reviews: 1207,
        badge: '5%',
        icon: Icons.lunch_dining_rounded,
      ),
      _MasgibPlace(
        name: '동네 이자카야',
        area: '도보 9분',
        menu: '사케 & 꼬치 모둠',
        rating: 4.7,
        reviews: 760,
        badge: '10%',
        icon: Icons.wine_bar_rounded,
      ),
    ],
  ),
  _MasgibTab(
    title: '인기 메뉴',
    subtitle: '최근 일주일 가장 많이 찾은 메뉴',
    items: [
      _MasgibPlace(
        name: '마라탕 전문점',
        area: '서울 강남',
        menu: '시그니처 마라탕',
        rating: 4.6,
        reviews: 3120,
        badge: 'HOT',
        icon: Icons.local_fire_department_rounded,
      ),
      _MasgibPlace(
        name: '대왕 카스텔라 카페',
        area: '서울 성수',
        menu: '클래식 카스텔라',
        rating: 4.8,
        reviews: 2045,
        badge: 'HOT',
        icon: Icons.local_cafe_rounded,
      ),
      _MasgibPlace(
        name: '국물 떡볶이집',
        area: '서울 신당',
        menu: '로제 떡볶이',
        rating: 4.7,
        reviews: 2680,
        badge: 'HOT',
        icon: Icons.rice_bowl_rounded,
      ),
    ],
  ),
];

/// 📑 TabBar Delegate
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate(this.child);

  @override
  double get minExtent => 46;

  @override
  double get maxExtent => 46;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
