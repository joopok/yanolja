import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

/// 🍽️ 맛집 화면 — 야놀자 핑크 플랫 디자인
/// 보라색/블루 그라데이션 및 멤버십 흔적을 제거하고
/// 야놀자 디자인 언어(화이트 배경 · 핑크 포인트 · 플랫 카드)로 재구성했습니다.
class MasgibScreen extends ConsumerStatefulWidget {
  const MasgibScreen({super.key});

  @override
  ConsumerState<MasgibScreen> createState() => _MasgibScreenState();
}

class _MasgibScreenState extends ConsumerState<MasgibScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanoljaColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildTabBar(),
          _buildMainBanner(),
          _buildSectionGap(),
          _buildServiceGrid(),
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
    return SliverAppBar(
      pinned: true,
      backgroundColor: YanoljaColors.background,
      surfaceTintColor: YanoljaColors.background,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleSpacing: 20,
      title: const Text(
        '맛집',
        style: TextStyle(
          color: YanoljaColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.search_rounded,
            color: YanoljaColors.textPrimary,
            size: 24,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.bookmark_border_rounded,
            color: YanoljaColors.textPrimary,
            size: 24,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// 핑크 인디케이터 탭바 (화이트 배경 + 헤어라인)
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
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
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

  /// 메인 프로모션 배너 — 연핑크 틴트 플랫 카드
  Widget _buildMainBanner() {
    return SliverToBoxAdapter(
      child: AnimationLimiter(
        child: AnimationConfiguration.staggeredList(
          position: 0,
          duration: const Duration(milliseconds: 300),
          child: SlideAnimation(
            verticalOffset: 20.0,
            child: FadeInAnimation(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                height: 160,
                decoration: BoxDecoration(
                  color: YanoljaColors.primaryLight,
                  borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                  border: Border.all(color: YanoljaColors.border),
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
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: YanoljaColors.primary,
                              borderRadius:
                                  BorderRadius.circular(YanoljaRadius.sm),
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
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: YanoljaColors.border),
                          ),
                          child: const Icon(
                            Icons.restaurant_rounded,
                            color: YanoljaColors.primary,
                            size: 40,
                          ),
                        ),
                      ),
                    ),

                    // 페이지 인디케이터 (플랫 핑크 칩)
                    Positioned(
                      bottom: 14,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(YanoljaRadius.pill),
                          border: Border.all(color: YanoljaColors.border),
                        ),
                        child: const Text(
                          '4 / 10',
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

  /// 카테고리 그리드 (4x2) — 플랫 핑크 틴트 아이콘
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
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: AnimationLimiter(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 16,
              childAspectRatio: 0.82,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 300),
                columnCount: 4,
                child: FadeInAnimation(
                  child: SlideAnimation(
                    verticalOffset: 20.0,
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

  /// 카테고리 카드 — 연핑크 배경 + 핑크 아이콘 (플랫)
  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Column(
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
          service['title'] as String,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
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

  /// 프로모션 카드 — 화이트 카드 + 헤어라인, 핑크 포인트
  Widget _buildPromotionCard() {
    final items = [
      {'tag': 'D-3', 'name': '뚜레쥬르', 'menu': '베이커리 10% 할인'},
      {'tag': 'D-5', 'name': '본가설렁탕', 'menu': '식사권 5천원 할인'},
      {'tag': 'D-7', 'name': '정원식당', 'menu': '디저트 무료 제공'},
    ];

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: YanoljaColors.surface,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
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
                    borderRadius:
                        BorderRadius.circular(YanoljaRadius.md),
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
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 하단 멤버 정보 — 화이트 카드 + 핑크 포인트 (플랫)
  Widget _buildBottomInfo() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: YanoljaColors.surface,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
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
                          horizontal: 8,
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
                        '도승현님',
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

            // 오른쪽 쿠폰 버튼 (핑크 필 버튼)
            Container(
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
