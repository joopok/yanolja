import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';

/// NOL(야놀자) 스타일 홈 화면
///
/// 현재 NOL 앱의 홈 구성을 재현합니다.
/// 1) NOL 로고 + 검색 진입
/// 2) 카테고리 아이콘 그리드
/// 3) 프로모션 배너 캐러셀
/// 4) 혜택 바로가기
/// 5) 특가/인기/내 주변 숙소 섹션
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _bannerIndex = 0;
  final Set<String> _liked = {};

  static const _fallbackImage =
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800';

  @override
  Widget build(BuildContext context) {
    final accommodations = ref.watch(accommodationListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: YanoljaColors.primary,
        onRefresh: () async => ref.invalidate(accommodationListProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildCategoryGrid()),
            SliverToBoxAdapter(child: _buildBannerCarousel()),
            SliverToBoxAdapter(child: _buildBenefitShortcuts()),
            SliverToBoxAdapter(child: const _SectionDivider()),
            ...accommodations.when(
              data: (data) => _buildContentSlivers(data),
              loading: () => [_buildShimmerSliver()],
              error: (e, _) => [_buildErrorSliver(e)],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 헤더 (NOL 로고 + 검색 바 + 공지)
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, topPad + 12, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      YanoljaColors.primary,
                      YanoljaColors.primaryPurple
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'N',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'NOL',
                style: TextStyle(
                  color: YanoljaColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  height: 1,
                ),
              ),
              const Spacer(),
              _headerIcon(Icons.card_giftcard_outlined, () => _soon('쿠폰')),
              _headerIcon(Icons.shopping_bag_outlined, () => _soon('장바구니')),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _headerIcon(
                      Icons.notifications_none_rounded, () => _soon('알림')),
                  Positioned(
                    right: 7,
                    top: 7,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: YanoljaColors.sale,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => context.push('/search'),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5FA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: YanoljaColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search_rounded,
                      color: YanoljaColors.textPrimary, size: 25),
                  SizedBox(width: 12),
                  Text(
                    '무엇을 하고 놀까요?',
                    style: TextStyle(
                      color: YanoljaColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _soon('NOL 소식'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: YanoljaColors.primaryLight,
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    color: YanoljaColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '야놀자의 새 이름, NOL에서 더 많은 혜택을 만나보세요',
                      style: TextStyle(
                        color: YanoljaColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: YanoljaColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: YanoljaColors.textPrimary, size: 24),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 카테고리 아이콘 그리드 (NOL 시그니처 메뉴)
  // ─────────────────────────────────────────────────────────────
  Widget _buildCategoryGrid() {
    final items = <_Category>[
      _Category('항공', Icons.flight_takeoff_rounded, const Color(0xFF22A7FF),
          () => _soon('항공')),
      _Category('해외숙소', Icons.luggage_rounded, const Color(0xFF4C6FFF),
          () => _soon('해외숙소')),
      _Category('레저/티켓', Icons.attractions_rounded, const Color(0xFFFF4FB7),
          () => _soon('레저/티켓')),
      _Category('공연/전시', Icons.theater_comedy_rounded, const Color(0xFFFF7A45),
          () => _soon('공연/전시')),
      _Category('교통', Icons.directions_bus_rounded, const Color(0xFFFF4D4F),
          () => _soon('교통')),
      _Category('호텔/리조트', Icons.apartment_rounded, const Color(0xFF6B5CFF),
          () => context.push('/resort')),
      _Category('펜션/풀빌라', Icons.beach_access_rounded, const Color(0xFF00B894),
          () => context.push('/pension')),
      _Category('프리미엄', Icons.workspace_premium_rounded,
          const Color(0xFF213B80), () => context.push('/hotel')),
      _Category('글램핑/캠핑', Icons.park_rounded, const Color(0xFF00C2B8),
          () => _soon('글램핑/캠핑')),
      _Category('모텔', Icons.king_bed_rounded, const Color(0xFFFFA726),
          () => context.push('/hotel')),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 18, 8, 6),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 16,
          childAspectRatio: 0.74,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) => _buildCategoryItem(items[i]),
      ),
    );
  }

  Widget _buildCategoryItem(_Category item) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        item.onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: item.color, size: 27),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: YanoljaColors.textPrimary,
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 프로모션 배너 캐러셀
  // ─────────────────────────────────────────────────────────────
  Widget _buildBannerCarousel() {
    final banners = [
      const _PromoBanner(
        badge: 'NOL 새 출발',
        title: '처음 인사드려요!\nNOL이라고 합니다',
        subtitle: '야놀자의 새 이름, NOL',
        image:
            'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=900',
        id: '1',
        colors: [Color(0xFF08111F), Color(0xFF1D4DFF)],
      ),
      const _PromoBanner(
        badge: '국내숙소',
        title: '국내숙소 최대 81%\n특가까지',
        subtitle: '여름 여행 준비 NOLDAY',
        image:
            'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=900',
        id: '2',
        colors: [Color(0xFFFF8067), Color(0xFFFFC0A7)],
      ),
      const _PromoBanner(
        badge: '호텔 쿠폰',
        title: '5성급 호텔 최대 13%\n쿠폰 할인',
        subtitle: '4만 코인 페이백까지',
        image:
            'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=900',
        id: '3',
        colors: [Color(0xFFFF6D93), Color(0xFFFFC0CE)],
      ),
      const _PromoBanner(
        badge: 'NOL 라이브',
        title: '오늘만 만나는\n라이브 특가',
        subtitle: '숙소부터 항공까지 한 번에',
        image:
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=900',
        id: '4',
        colors: [Color(0xFF00B8A9), Color(0xFF59D6C8)],
      ),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 158,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              viewportFraction: 0.9,
              enlargeCenterPage: false,
              onPageChanged: (i, _) => setState(() => _bannerIndex = i),
            ),
            items: banners.map(_buildBannerCard).toList(),
          ),
          const SizedBox(height: 13),
          _buildBannerProgress(banners.length),
        ],
      ),
    );
  }

  Widget _buildBannerCard(_PromoBanner banner) {
    return GestureDetector(
      onTap: () => context.push('/detail/${banner.id}'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: banner.colors,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: banner.image,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    banner.colors.first.withValues(alpha: 0.98),
                    banner.colors.first.withValues(alpha: 0.72),
                    banner.colors.last.withValues(alpha: 0.26),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              right: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                    ),
                    child: Text(
                      banner.badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    banner.subtitle,
                    style: const TextStyle(
                      color: Color(0xE6FFFFFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
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

  Widget _buildBannerProgress(int count) {
    final progress = (_bannerIndex + 1) / count;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.pause_rounded,
          size: 17,
          color: YanoljaColors.textPrimary,
        ),
        const SizedBox(width: 8),
        Container(
          width: 82,
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xFFE3E5E9),
            borderRadius: BorderRadius.circular(1),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: YanoljaColors.textPrimary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${(_bannerIndex + 1).toString().padLeft(2, '0')} / ${count.toString().padLeft(2, '0')} +',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitShortcuts() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FB),
              borderRadius: BorderRadius.circular(YanoljaRadius.md),
              border: Border.all(color: YanoljaColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _benefitCell(
                    icon: Icons.card_giftcard_rounded,
                    label: 'NOL드로우',
                    color: YanoljaColors.sale,
                  ),
                ),
                const _BenefitDivider(),
                Expanded(
                  child: _benefitCell(
                    icon: Icons.fact_check_rounded,
                    label: '이달쿠폰팩',
                    color: YanoljaColors.primary,
                  ),
                ),
                const _BenefitDivider(),
                Expanded(
                  child: _benefitCell(
                    icon: Icons.celebration_rounded,
                    label: '이벤트더보기',
                    color: Color(0xFFFF7A45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _soon('첫 구매 혜택'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6DD),
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.savings_rounded,
                    color: Color(0xFFFFA000),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '첫 구매 최대 1.2만 코인 페이백',
                          style: TextStyle(
                            color: YanoljaColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          '항공권 10% 쿠폰도 지급 중!',
                          style: TextStyle(
                            color: YanoljaColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: YanoljaColors.textTertiary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitCell({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _soon(label),
      borderRadius: BorderRadius.circular(YanoljaRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: YanoljaColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 콘텐츠 (데이터 기반 섹션들)
  // ─────────────────────────────────────────────────────────────
  List<Widget> _buildContentSlivers(List<Accommodation> all) {
    if (all.isEmpty) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: Text('표시할 숙소가 없습니다')),
          ),
        ),
      ];
    }

    final popular = all.where((a) => a.isPopular).toList();
    final hotList = popular.isNotEmpty ? popular : all;

    final trending = [...all]
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));

    final nearby = all.take(8).toList();

    return [
      _buildHorizontalSection(
        title: 'NOL 라이브 놀라운 혜택!',
        subtitle: '실시간 특가와 단독 혜택을 모았어요',
        items: hotList.take(10).toList(),
      ),
      const SliverToBoxAdapter(child: _SectionDivider()),
      _buildHorizontalSection(
        title: '관심지역의 많이 찾는 숙소',
        subtitle: '최근 여행자들이 가장 많이 본 곳',
        items: trending.take(10).toList(),
      ),
      const SliverToBoxAdapter(child: _SectionDivider()),
      SliverToBoxAdapter(
        child: YanoljaSectionHeader(
          title: '내 주변에서 바로 예약 가능한 숙소',
          subtitle: '가까운 거리순으로 둘러보세요',
          trailingText: '전체',
          onTrailingTap: () => context.go('/nearby'),
        ),
      ),
      _buildVerticalList(nearby),
    ];
  }

  Widget _buildHorizontalSection({
    required String title,
    required String subtitle,
    required List<Accommodation> items,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YanoljaSectionHeader(title: title, subtitle: subtitle),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) => _buildHorizontalCard(items[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCard(Accommodation a) {
    final rate = YanoljaFormat.discountRate(a.id);
    final original = YanoljaFormat.originalPrice(a.price, rate);
    final image = a.imageUrls.isNotEmpty ? a.imageUrls.first : _fallbackImage;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/detail/${a.id}');
      },
      child: SizedBox(
        width: 170,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: image,
                    width: 170,
                    height: 160,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: YanoljaColors.surfaceAlt),
                    errorWidget: (_, __, ___) =>
                        Container(color: YanoljaColors.surfaceAlt),
                  ),
                  if (a.isNew)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _tag('신규', YanoljaColors.accentBlue),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _heartButton(a.id),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${a.category} · ${_shortAddress(a.address)}',
              style: const TextStyle(
                fontSize: 11.5,
                color: YanoljaColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              a.name,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            YanoljaRating(rating: a.rating, reviewCount: a.reviewCount),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$rate%',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.sale,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${YanoljaFormat.price(a.price)}원',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              '${YanoljaFormat.price(original)}원',
              style: const TextStyle(
                fontSize: 11.5,
                color: YanoljaColors.textTertiary,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 세로 리스트 (가로형 카드)
  // ─────────────────────────────────────────────────────────────
  Widget _buildVerticalList(List<Accommodation> items) {
    return SliverList.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Divider(height: 1, color: YanoljaColors.divider),
      ),
      itemBuilder: (context, i) => _buildVerticalCard(items[i]),
    );
  }

  Widget _buildVerticalCard(Accommodation a) {
    final rate = YanoljaFormat.discountRate(a.id);
    final original = YanoljaFormat.originalPrice(a.price, rate);
    final image = a.imageUrls.isNotEmpty ? a.imageUrls.first : _fallbackImage;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/detail/${a.id}');
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: image,
                    width: 116,
                    height: 116,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: YanoljaColors.surfaceAlt),
                    errorWidget: (_, __, ___) =>
                        Container(color: YanoljaColors.surfaceAlt),
                  ),
                  Positioned(top: 6, right: 6, child: _heartButton(a.id)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (a.isPopular) _tag('인기', YanoljaColors.primary),
                      if (a.isPopular) const SizedBox(width: 4),
                      Text(
                        a.category,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: YanoljaColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    a.name,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _shortAddress(a.address),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: YanoljaColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  YanoljaRating(rating: a.rating, reviewCount: a.reviewCount),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${YanoljaFormat.price(original)}원',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: YanoljaColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$rate% ',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: YanoljaColors.sale,
                        ),
                      ),
                      Text(
                        '${YanoljaFormat.price(a.price)}원',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
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

  // ─────────────────────────────────────────────────────────────
  // 공용 위젯
  // ─────────────────────────────────────────────────────────────
  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _heartButton(String id) {
    final liked = _liked.contains(id);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          if (liked) {
            _liked.remove(id);
          } else {
            _liked.add(id);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        child: Icon(
          liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: liked ? YanoljaColors.primary : Colors.white,
          size: 22,
          shadows: const [
            Shadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
      ),
    );
  }

  String _shortAddress(String address) {
    final parts = address.split(' ');
    if (parts.length >= 2) return '${parts[0]} ${parts[1]}';
    return address;
  }

  void _soon(String label) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label 기능은 준비 중이에요'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  // ─────────────────────────────────────────────────────────────
  // 로딩 / 에러
  // ─────────────────────────────────────────────────────────────
  Widget _buildShimmerSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Shimmer.fromColors(
          baseColor: const Color(0xFFEDEEF0),
          highlightColor: const Color(0xFFF7F8FA),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 160,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (context, i) => Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildErrorSliver(Object error) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: YanoljaColors.textTertiary),
            const SizedBox(height: 12),
            const Text(
              '숙소 정보를 불러오지 못했어요',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.invalidate(accommodationListProvider),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(120, 44),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 섹션 구분용 두꺼운 라이트 그레이 띠
class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 8, color: YanoljaColors.surfaceAlt);
  }
}

class _Category {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _Category(this.label, this.icon, this.color, this.onTap);
}

class _PromoBanner {
  final String badge;
  final String title;
  final String subtitle;
  final String image;
  final String id;
  final List<Color> colors;

  const _PromoBanner({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.id,
    required this.colors,
  });
}

class _BenefitDivider extends StatelessWidget {
  const _BenefitDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 22,
      color: YanoljaColors.border,
    );
  }
}
