import 'dart:async';

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
import 'package:yanolja_clone/presentation/provider/notification_provider.dart';
import 'package:yanolja_clone/presentation/provider/search_provider.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';
import 'package:yanolja_clone/presentation/widget/nol_footer.dart';

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

  /// "호캉스 어디로 갈까?" 지역 탭에서 현재 선택된 지역.
  String _selectedRegion = '서울';

  /// 지역 탭 → 주소 매칭 키워드 (라이브 NOL의 지역 호캉스 탭 재현).
  static const Map<String, List<String>> _regionKeywords = {
    '서울': ['서울'],
    '강원': ['강원', '강릉', '속초', '평창', '양양', '정선', '춘천'],
    '제주': ['제주', '서귀포'],
    '부산·경상': ['부산', '경주', '대구', '울산', '경상', '포항', '창원'],
    '전라·충청': ['전주', '여수', '전라', '광주', '충청', '대전', '천안', '아산'],
  };

  static const List<String> _notices = [
    '야놀자의 새 이름, NOL에서 더 많은 혜택을 만나보세요',
    'NOLDAY 국내 숙소 특가와 쿠폰이 열렸어요',
    '공연·전시 티켓 예매 오픈 소식을 확인해보세요',
    '여름 여행 예약 전 취소·환불 규정을 확인해주세요',
  ];

  static const _fallbackImage =
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800';

  @override
  Widget build(BuildContext context) {
    final accommodations = ref.watch(accommodationListProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

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
            YanoljaSliverAppBar.main(
              title: 'NOL',
              subtitle: '숙소, 티켓, 혜택을 빠르게 예약하세요',
              actions: [
                _headerIcon(
                  Icons.card_giftcard_outlined,
                  () => _openService('coupons'),
                ),
                _headerIcon(
                  Icons.shopping_bag_outlined,
                  () => _openService('cart'),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _headerIcon(
                      Icons.notifications_none_rounded,
                      () => context.push('/notifications'),
                    ),
                    // 안 읽은 알림이 있을 때만, 실제 미확인 개수를 배지로 표시.
                    if (unreadCount > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.xs),
                          constraints: const BoxConstraints(minWidth: 17),
                          height: 17,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: YanoljaColors.sale,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(child: YanoljaEntrance(child: _buildHeader())),
            SliverToBoxAdapter(
              child: YanoljaEntrance(
                delay: const Duration(milliseconds: 60),
                child: _buildCategoryGrid(),
              ),
            ),
            SliverToBoxAdapter(
              child: YanoljaEntrance(
                delay: const Duration(milliseconds: 110),
                child: _buildBannerCarousel(),
              ),
            ),
            SliverToBoxAdapter(
              child: YanoljaEntrance(
                delay: const Duration(milliseconds: 160),
                child: _buildBenefitShortcuts(),
              ),
            ),
            SliverToBoxAdapter(child: const _SectionDivider()),
            ...accommodations.when(
              data: (data) => _buildContentSlivers(data),
              loading: () => [_buildShimmerSliver()],
              error: (e, _) => [_buildErrorSliver(e)],
            ),
            const SliverToBoxAdapter(child: _SectionDivider()),
            const SliverToBoxAdapter(child: NolFooter()),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 헤더 (NOL 로고 + 검색 바 + 공지)
  // ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YanoljaPressable(
            onTap: () => context.go('/search'),
            child: Container(
              height: 56,
              padding: const EdgeInsets.fromLTRB(18, 0, 9, 0),
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
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      color: YanoljaColors.textPrimary, size: 25),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '어디로 떠나볼까요?',
                      style: TextStyle(
                        color: YanoljaColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  _buildVoiceSearchButton(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          YanoljaPressable(
            onTap: () => _openService('news'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: YanoljaColors.primaryLight,
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.campaign_outlined,
                    color: YanoljaColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: YanoljaSpacing.s),
                  const Expanded(
                    child: _RollingNotice(notices: _notices),
                  ),
                  const Icon(
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

  /// 홈 검색바 우측의 음성 검색 버튼.
  /// 탭하면 검색 화면으로 이동하면서 음성 인식을 바로 시작한다.
  Widget _buildVoiceSearchButton() {
    return Semantics(
      button: true,
      label: '음성으로 검색',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.mediumImpact();
          ref.read(voiceSearchSignalProvider.notifier).state++;
          context.go('/search');
        },
        child: Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: YanoljaColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mic_none_rounded,
            color: YanoljaColors.primary,
            size: 21,
          ),
        ),
      ),
    );
  }

  Widget _headerIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(YanoljaSpacing.s),
        child: Icon(icon, color: YanoljaColors.textPrimary, size: 24),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 카테고리 아이콘 그리드 (NOL 시그니처 메뉴)
  // ─────────────────────────────────────────────────────────────
  Widget _buildCategoryGrid() {
    // 라이브 NOL(nol.yanolja.com) 홈의 카테고리 아이콘 세트·순서를 그대로 재현.
    final items = <_Category>[
      _Category(
        label: '호텔/리조트',
        art: _CategoryArt.hotel,
        baseColor: const Color(0xFF5B43FF),
        accentColor: const Color(0xFF8E7BFF),
        onTap: () => context.push('/hotel'),
      ),
      _Category(
        label: '펜션/풀빌라',
        art: _CategoryArt.pension,
        baseColor: const Color(0xFF00AFA3),
        accentColor: const Color(0xFF7CE7D6),
        onTap: () => context.push('/pension'),
      ),
      _Category(
        label: '모텔',
        art: _CategoryArt.motel,
        baseColor: const Color(0xFFFF9F1C),
        accentColor: const Color(0xFFFFE06D),
        onTap: () => _openService('motel'),
      ),
      _Category(
        label: '국내레저',
        art: _CategoryArt.leisure,
        baseColor: const Color(0xFFFF4FB7),
        accentColor: const Color(0xFFFFB347),
        onTap: () => _openService('leisure'),
      ),
      _Category(
        label: '교통/쏘카',
        art: _CategoryArt.traffic,
        baseColor: const Color(0xFFFF4D5C),
        accentColor: const Color(0xFF5067FF),
        onTap: () => _openService('transport'),
      ),
      _Category(
        label: 'NOL 티켓',
        art: _CategoryArt.show,
        baseColor: const Color(0xFFFF6D3D),
        accentColor: const Color(0xFFFFC04D),
        onTap: () => context.push('/ticket'),
      ),
      _Category(
        label: '항공',
        art: _CategoryArt.flight,
        baseColor: const Color(0xFF2F6BFF),
        accentColor: const Color(0xFF66D7FF),
        onTap: () => _openService('flight'),
      ),
      _Category(
        label: '해외숙소',
        art: _CategoryArt.overseas,
        baseColor: const Color(0xFF4C6FFF),
        accentColor: const Color(0xFF00C2FF),
        onTap: () => _openService('overseas'),
      ),
      _Category(
        label: '해외투어',
        art: _CategoryArt.tour,
        baseColor: const Color(0xFF00B8A0),
        accentColor: const Color(0xFF7CE7D6),
        onTap: () => _openService('overseas-tour'),
      ),
      _Category(
        label: '해외패키지',
        art: _CategoryArt.package,
        baseColor: const Color(0xFF7C5BFF),
        accentColor: const Color(0xFFC0A8FF),
        onTap: () => _openService('package'),
      ),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 18, 8, 12),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 18,
              childAspectRatio: 0.7,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => YanoljaEntrance(
              delay: YanoljaMotion.stagger(i, start: 0, step: 20),
              beginOffset: const Offset(0, 0.03),
              child: _buildCategoryItem(items[i]),
            ),
          ),
          const SizedBox(height: 14),
          _buildAllCategoriesButton(),
        ],
      ),
    );
  }

  /// 전체 카테고리 화면 진입 버튼
  Widget _buildAllCategoriesButton() {
    return YanoljaPressable(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/all-categories');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.s),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: YanoljaColors.surfaceAlt,
          borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view_rounded, size: 18, color: Color(0xFF6F6F6F)),
            SizedBox(width: 6),
            Text(
              '전체 카테고리 보기',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(width: 2),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: Color(0xFFA9ADB4)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(_Category item) {
    return YanoljaPressable(
      onTap: () {
        HapticFeedback.lightImpact();
        item.onTap();
      },
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.baseColor.withValues(alpha: 0.12),
                  item.accentColor.withValues(alpha: 0.18),
                ],
              ),
              borderRadius: BorderRadius.circular(21),
              boxShadow: [
                BoxShadow(
                  color: item.baseColor.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _CategoryIconPainter(
                art: item.art,
                baseColor: item.baseColor,
                accentColor: item.accentColor,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 11.2,
              fontWeight: FontWeight.w700,
              color: YanoljaColors.textPrimary,
              letterSpacing: -0.4,
              height: 1.18,
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
    return YanoljaPressable(
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
                        const EdgeInsets.symmetric(horizontal: 9, vertical: YanoljaSpacing.xs),
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
                  const SizedBox(height: YanoljaSpacing.s),
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
        const SizedBox(width: YanoljaSpacing.s),
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
                    onTap: () => _openService('draw'),
                  ),
                ),
                const _BenefitDivider(),
                Expanded(
                  child: _benefitCell(
                    icon: Icons.fact_check_rounded,
                    label: '이달쿠폰팩',
                    color: YanoljaColors.primary,
                    onTap: () => _openService('coupons'),
                  ),
                ),
                const _BenefitDivider(),
                Expanded(
                  child: _benefitCell(
                    icon: Icons.celebration_rounded,
                    label: '이벤트더보기',
                    color: Color(0xFFFF7A45),
                    onTap: () => _openService('deals'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          YanoljaPressable(
            onTap: () => _openService('first-benefit'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.m, vertical: 15),
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
        title: '오늘 바로 잡는 라이브 특가',
        subtitle: '실시간 혜택과 단독 쿠폰을 모았어요',
        items: hotList.take(10).toList(),
      ),
      const SliverToBoxAdapter(child: _SectionDivider()),
      _buildHorizontalSection(
        title: '요즘 많이 보는 숙소',
        subtitle: '최근 여행자 관심이 높은 곳부터 보여드려요',
        items: trending.take(10).toList(),
      ),
      const SliverToBoxAdapter(child: _SectionDivider()),
      _buildRegionSection(all),
      const SliverToBoxAdapter(child: _SectionDivider()),
      _buildCurationStrip(),
      const SliverToBoxAdapter(child: _SectionDivider()),
      SliverToBoxAdapter(
        child: YanoljaSectionHeader(
          title: '내 주변에서 바로 예약 가능한 숙소',
          subtitle: '현재 위치 기준 가까운 곳부터 둘러보세요',
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
              itemBuilder: (context, i) => YanoljaEntrance(
                delay: YanoljaMotion.stagger(i, start: 0, step: 35),
                child: _buildHorizontalCard(items[i]),
              ),
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

    return YanoljaPressable(
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
            const SizedBox(height: YanoljaSpacing.s),
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
            const SizedBox(height: YanoljaSpacing.xs),
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
  // 지역 탭형 호캉스 특가 (라이브 NOL "호캉스 어디로 갈까?" 재현)
  // ─────────────────────────────────────────────────────────────
  Widget _buildRegionSection(List<Accommodation> all) {
    final keywords = _regionKeywords[_selectedRegion] ?? const [];
    var matches =
        all.where((a) => keywords.any((k) => a.address.contains(k))).toList();
    if (matches.isEmpty) matches = all;
    matches = matches.take(10).toList();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const YanoljaSectionHeader(
            title: '놀라운 특가, 호캉스 어디로 갈까?',
            subtitle: '지역을 골라 인기 호캉스 특가를 둘러보세요',
          ),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l),
              itemCount: _regionKeywords.length,
              separatorBuilder: (_, __) => const SizedBox(width: YanoljaSpacing.s),
              itemBuilder: (context, i) {
                final region = _regionKeywords.keys.elementAt(i);
                final selected = region == _selectedRegion;
                return YanoljaPressable(
                  pressedScale: 0.97,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedRegion = region);
                  },
                  child: AnimatedContainer(
                    duration: YanoljaMotion.base,
                    curve: YanoljaMotion.curve,
                    padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.m),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? YanoljaColors.primary
                          : YanoljaColors.surface,
                      borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                      border: Border.all(
                        color: selected
                            ? YanoljaColors.primary
                            : YanoljaColors.border,
                      ),
                    ),
                    child: Text(
                      region,
                      style: TextStyle(
                        color:
                            selected ? Colors.white : YanoljaColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) => _buildHorizontalCard(matches[i]),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 기획전 모음 (라이브 NOL "기획전 모음" 재현)
  // ─────────────────────────────────────────────────────────────
  Widget _buildCurationStrip() {
    const curations = <_Curation>[
      _Curation(
        tag: '할인혜택',
        title: '여름 펜션, 최대 70% 할인',
        subtitle: '총 20만원 쿠폰팩 혜택 받기',
        colors: [Color(0xFF315BFF), Color(0xFF5B8DEF)],
        service: 'deals',
      ),
      _Curation(
        tag: '이벤트',
        title: '빠지 근처 펜션 모아보기',
        subtitle: '차량·도보 10분 이내 숙소만',
        colors: [Color(0xFF00B8A9), Color(0xFF59D6C8)],
        service: 'event',
      ),
      _Curation(
        tag: 'MD추천',
        title: '숙소&레저 한 번에 해결',
        subtitle: '숙소 예약하면 레저 티켓 제공',
        colors: [Color(0xFFFF7A45), Color(0xFFFFB36B)],
        service: 'leisure',
      ),
      _Curation(
        tag: 'MD추천',
        title: '10만원 이하 가성비 펜션',
        subtitle: '믿기지 않는 가격과 퀄리티',
        colors: [Color(0xFF7C5BFF), Color(0xFFB39BFF)],
        service: 'coupons',
      ),
    ];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YanoljaSectionHeader(
            title: '기획전 모음',
            subtitle: 'NOL이 준비한 테마 기획전을 만나보세요',
            trailingText: '전체',
            onTrailingTap: () => _openService('event'),
          ),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              itemCount: curations.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _buildCurationCard(curations[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurationCard(_Curation c) {
    return YanoljaPressable(
      onTap: () {
        HapticFeedback.lightImpact();
        _openService(c.service);
      },
      child: Container(
        width: 230,
        padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: c.colors,
          ),
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          boxShadow: [
            BoxShadow(
              color: c.colors.last.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: YanoljaSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(YanoljaRadius.pill),
              ),
              child: Text(
                c.tag,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Spacer(),
            Text(
              c.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
                height: 1.22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              c.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
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
        padding: EdgeInsets.symmetric(horizontal: YanoljaSpacing.l),
        child: Divider(height: 1, color: YanoljaColors.divider),
      ),
      itemBuilder: (context, i) => YanoljaEntrance(
        delay: YanoljaMotion.stagger(i, start: 0, step: 35),
        child: _buildVerticalCard(items[i]),
      ),
    );
  }

  Widget _buildVerticalCard(Accommodation a) {
    final rate = YanoljaFormat.discountRate(a.id);
    final original = YanoljaFormat.originalPrice(a.price, rate);
    final image = a.imageUrls.isNotEmpty ? a.imageUrls.first : _fallbackImage;

    return YanoljaPressable(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/detail/${a.id}');
      },
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
                      if (a.isPopular) const SizedBox(width: YanoljaSpacing.xs),
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
                  const SizedBox(height: YanoljaSpacing.s),
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

  void _openService(String type) {
    HapticFeedback.selectionClick();
    context.push('/service/$type');
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
              const SizedBox(height: YanoljaSpacing.m),
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
            const SizedBox(height: YanoljaSpacing.m),
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

class _RollingNotice extends StatefulWidget {
  final List<String> notices;

  const _RollingNotice({required this.notices});

  @override
  State<_RollingNotice> createState() => _RollingNoticeState();
}

class _RollingNoticeState extends State<_RollingNotice> {
  late final PageController _pageController;
  Timer? _timer;
  int _page = 1000;
  bool _tickerEnabled = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _page);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tickerEnabled = TickerMode.valuesOf(context).enabled;
  }

  @override
  void didUpdateWidget(covariant _RollingNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notices.length != widget.notices.length) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!mounted || widget.notices.length < 2) return;
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _showNextNotice(),
    );
  }

  void _showNextNotice() {
    if (!mounted || !_tickerEnabled || !_pageController.hasClients) return;

    _page++;
    if (YanoljaMotion.reduce(context)) {
      _pageController.jumpToPage(_page);
      return;
    }

    _pageController.animateToPage(
      _page,
      duration: const Duration(milliseconds: 360),
      curve: YanoljaMotion.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final notice = widget.notices[index % widget.notices.length];
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              notice,
              style: const TextStyle(
                color: YanoljaColors.textPrimary,
                fontSize: 12.5,
                height: 1.2,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
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

enum _CategoryArt {
  flight,
  overseas,
  leisure,
  show,
  traffic,
  hotel,
  pension,
  motel,
  tour,
  package,
}

class _Category {
  final String label;
  final _CategoryArt art;
  final Color baseColor;
  final Color accentColor;
  final VoidCallback onTap;
  const _Category({
    required this.label,
    required this.art,
    required this.baseColor,
    required this.accentColor,
    required this.onTap,
  });
}

class _CategoryIconPainter extends CustomPainter {
  final _CategoryArt art;
  final Color baseColor;
  final Color accentColor;

  const _CategoryIconPainter({
    required this.art,
    required this.baseColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 58, size.height / 58);
    _drawAmbient(canvas);

    switch (art) {
      case _CategoryArt.flight:
        _drawFlight(canvas);
        break;
      case _CategoryArt.overseas:
        _drawOverseas(canvas);
        break;
      case _CategoryArt.leisure:
        _drawLeisure(canvas);
        break;
      case _CategoryArt.show:
        _drawShow(canvas);
        break;
      case _CategoryArt.traffic:
        _drawTraffic(canvas);
        break;
      case _CategoryArt.hotel:
        _drawHotel(canvas);
        break;
      case _CategoryArt.pension:
        _drawPension(canvas);
        break;
      case _CategoryArt.motel:
        _drawMotel(canvas);
        break;
      case _CategoryArt.tour:
        _drawTour(canvas);
        break;
      case _CategoryArt.package:
        _drawPackage(canvas);
        break;
    }

    canvas.restore();
  }

  void _drawAmbient(Canvas canvas) {
    canvas.drawCircle(Offset(44, 14), 8, _fill(Colors.white, 0.58));
    canvas.drawCircle(Offset(15, 43), 6, _fill(accentColor, 0.18));
  }

  void _drawFlight(Canvas canvas) {
    _drawCloud(canvas, const Offset(17, 38), 0.82);

    final shadow = Path()
      ..moveTo(14, 35)
      ..quadraticBezierTo(27, 40, 42, 34);
    canvas.drawPath(shadow, _stroke(baseColor, 3, alpha: 0.12));

    final plane = Path()
      ..moveTo(10, 30)
      ..lineTo(48, 14)
      ..quadraticBezierTo(50, 13, 49, 16)
      ..lineTo(35, 43)
      ..quadraticBezierTo(34, 46, 31, 43)
      ..lineTo(26, 32)
      ..lineTo(14, 35)
      ..quadraticBezierTo(11, 36, 10, 30)
      ..close();
    canvas.drawPath(plane, _fill(baseColor));

    final wing = Path()
      ..moveTo(26, 32)
      ..lineTo(36, 25)
      ..lineTo(31, 41)
      ..close();
    canvas.drawPath(wing, _fill(accentColor));
    canvas.drawLine(
      const Offset(18, 28),
      const Offset(42, 18),
      _stroke(Colors.white, 2.2, alpha: 0.72),
    );
  }

  void _drawOverseas(Canvas canvas) {
    canvas.drawCircle(Offset(29, 23), 15, _fill(accentColor, 0.95));
    canvas.drawCircle(Offset(29, 23), 15, _stroke(baseColor, 2.4));
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(29, 23), radius: 10),
      -1.2,
      2.4,
      false,
      _stroke(Colors.white, 1.7, alpha: 0.72),
    );
    canvas.drawLine(
      const Offset(14, 23),
      const Offset(44, 23),
      _stroke(Colors.white, 1.5, alpha: 0.68),
    );
    canvas.drawLine(
      const Offset(29, 8),
      const Offset(29, 38),
      _stroke(Colors.white, 1.5, alpha: 0.68),
    );

    final hotel = RRect.fromRectAndRadius(
      const Rect.fromLTWH(18, 29, 26, 18),
      const Radius.circular(6),
    );
    canvas.drawRRect(hotel, _fill(baseColor));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(23, 25, 16, 9),
        const Radius.circular(5),
      ),
      _stroke(baseColor, 2.2),
    );
    for (final offset in const [
      Offset(24, 35),
      Offset(31, 35),
      Offset(38, 35),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(offset.dx, offset.dy, 4, 4),
          const Radius.circular(1.2),
        ),
        _fill(Colors.white, 0.86),
      );
    }
  }

  void _drawLeisure(Canvas canvas) {
    canvas.drawCircle(Offset(38, 18), 8.5, _fill(accentColor, 0.94));
    canvas.drawCircle(Offset(38, 18), 8.5, _stroke(baseColor, 2));
    canvas.drawLine(
      const Offset(38, 26),
      const Offset(38, 36),
      _stroke(baseColor, 2),
    );

    canvas.save();
    canvas.translate(10, 22);
    canvas.rotate(-0.12);
    final ticket = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 35, 23),
          const Radius.circular(7),
        ),
      );
    canvas.drawPath(ticket, _fill(baseColor));
    canvas.drawCircle(Offset(0, 11.5), 3.8, _fill(Colors.white, 0.92));
    canvas.drawCircle(Offset(35, 11.5), 3.8, _fill(Colors.white, 0.92));
    canvas.drawLine(
      const Offset(13, 4),
      const Offset(13, 19),
      _stroke(Colors.white, 1.5, alpha: 0.58),
    );
    canvas.drawPath(_starPath(const Offset(25, 11), 5.2), _fill(accentColor));
    canvas.restore();
  }

  void _drawShow(Canvas canvas) {
    final stage = RRect.fromRectAndRadius(
      const Rect.fromLTWH(13, 16, 32, 28),
      const Radius.circular(9),
    );
    canvas.drawRRect(stage, _fill(baseColor));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 21, 22, 14),
        const Radius.circular(5),
      ),
      _fill(Colors.white, 0.92),
    );

    final curtainLeft = Path()
      ..moveTo(13, 16)
      ..quadraticBezierTo(22, 23, 18, 44)
      ..lineTo(13, 44)
      ..close();
    final curtainRight = Path()
      ..moveTo(45, 16)
      ..quadraticBezierTo(36, 23, 40, 44)
      ..lineTo(45, 44)
      ..close();
    canvas.drawPath(curtainLeft, _fill(accentColor));
    canvas.drawPath(curtainRight, _fill(accentColor));
    canvas.drawCircle(Offset(29, 28), 4.4, _fill(baseColor));
    canvas.drawArc(
      const Rect.fromLTWH(22, 28, 14, 8),
      0.05,
      3.04,
      false,
      _stroke(baseColor, 1.8),
    );
    canvas.drawLine(
      const Offset(17, 17),
      const Offset(41, 17),
      _stroke(Colors.white, 2, alpha: 0.55),
    );
  }

  void _drawTraffic(Canvas canvas) {
    final bus = RRect.fromRectAndRadius(
      const Rect.fromLTWH(12, 16, 34, 27),
      const Radius.circular(8),
    );
    canvas.drawRRect(bus, _fill(baseColor));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(17, 21, 24, 10),
        const Radius.circular(4),
      ),
      _fill(Colors.white, 0.92),
    );
    canvas.drawLine(
      const Offset(29, 21),
      const Offset(29, 31),
      _stroke(baseColor, 1.4, alpha: 0.5),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(20, 34, 18, 4),
        const Radius.circular(2),
      ),
      _fill(accentColor),
    );
    canvas.drawCircle(Offset(20, 44), 4.4, _fill(const Color(0xFF1F2440)));
    canvas.drawCircle(Offset(38, 44), 4.4, _fill(const Color(0xFF1F2440)));
    canvas.drawCircle(Offset(20, 44), 1.8, _fill(Colors.white, 0.8));
    canvas.drawCircle(Offset(38, 44), 1.8, _fill(Colors.white, 0.8));
    canvas.drawLine(
      const Offset(11, 50),
      const Offset(47, 50),
      _stroke(accentColor, 2.2, alpha: 0.55),
    );
  }

  void _drawHotel(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(14, 21, 12, 24),
        const Radius.circular(4),
      ),
      _fill(accentColor, 0.9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(24, 13, 21, 32),
        const Radius.circular(6),
      ),
      _fill(baseColor),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(29, 39, 10, 6),
        const Radius.circular(2),
      ),
      _fill(Colors.white, 0.92),
    );
    for (final offset in const [
      Offset(29, 19),
      Offset(37, 19),
      Offset(29, 27),
      Offset(37, 27),
      Offset(18, 28),
      Offset(18, 36),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(offset.dx, offset.dy, 4.5, 4.5),
          const Radius.circular(1.4),
        ),
        _fill(Colors.white, 0.82),
      );
    }
    canvas.drawLine(
      const Offset(27, 14),
      const Offset(42, 14),
      _stroke(Colors.white, 2, alpha: 0.55),
    );
  }

  void _drawPension(Canvas canvas) {
    canvas.drawCircle(Offset(42, 16), 6.5, _fill(accentColor, 0.9));
    final roof = Path()
      ..moveTo(13, 30)
      ..lineTo(29, 15)
      ..lineTo(45, 30)
      ..quadraticBezierTo(44, 33, 41, 32)
      ..lineTo(29, 22)
      ..lineTo(17, 32)
      ..quadraticBezierTo(14, 33, 13, 30)
      ..close();
    canvas.drawPath(roof, _fill(baseColor));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(17, 29, 24, 16),
        const Radius.circular(6),
      ),
      _fill(Colors.white, 0.96),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(26, 34, 7, 11),
        const Radius.circular(3),
      ),
      _fill(baseColor, 0.95),
    );
    canvas.drawLine(
      const Offset(12, 48),
      const Offset(46, 48),
      _stroke(accentColor, 3.2, alpha: 0.72),
    );
    canvas.drawArc(
      const Rect.fromLTWH(17, 43, 10, 7),
      0.1,
      2.9,
      false,
      _stroke(baseColor, 1.8, alpha: 0.58),
    );
    canvas.drawArc(
      const Rect.fromLTWH(31, 43, 10, 7),
      0.1,
      2.9,
      false,
      _stroke(baseColor, 1.8, alpha: 0.58),
    );
  }

  void _drawMotel(Canvas canvas) {
    canvas.drawCircle(Offset(43, 15), 7, _fill(accentColor, 0.95));
    canvas.drawCircle(Offset(46, 12), 7, _fill(Colors.white, 0.72));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(12, 28, 34, 14),
        const Radius.circular(5),
      ),
      _fill(baseColor),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, 22, 13, 9),
        const Radius.circular(4),
      ),
      _fill(Colors.white, 0.94),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 25, 13, 6),
        const Radius.circular(3),
      ),
      _fill(accentColor, 0.92),
    );
    canvas.drawLine(
      const Offset(15, 42),
      const Offset(15, 47),
      _stroke(baseColor, 3),
    );
    canvas.drawLine(
      const Offset(43, 42),
      const Offset(43, 47),
      _stroke(baseColor, 3),
    );
    canvas.drawPath(_starPath(const Offset(17, 16), 3.5), _fill(baseColor));
  }

  void _drawTour(Canvas canvas) {
    // 지구본
    canvas.drawCircle(const Offset(25, 25), 14, _fill(accentColor, 0.95));
    canvas.drawCircle(const Offset(25, 25), 14, _stroke(baseColor, 2.2));
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(25, 25), radius: 9),
      -1.1,
      2.2,
      false,
      _stroke(Colors.white, 1.6, alpha: 0.72),
    );
    canvas.drawLine(
      const Offset(11, 25),
      const Offset(39, 25),
      _stroke(Colors.white, 1.4, alpha: 0.66),
    );
    canvas.drawLine(
      const Offset(25, 11),
      const Offset(25, 39),
      _stroke(Colors.white, 1.4, alpha: 0.66),
    );
    // 투어 티켓 배지 (우하단)
    canvas.save();
    canvas.translate(29, 31);
    canvas.rotate(-0.18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 22, 15),
        const Radius.circular(5),
      ),
      _fill(baseColor),
    );
    canvas.drawCircle(const Offset(0, 7.5), 2.6, _fill(Colors.white, 0.95));
    canvas.drawCircle(const Offset(22, 7.5), 2.6, _fill(Colors.white, 0.95));
    canvas.drawPath(_starPath(const Offset(11, 7.5), 3.6), _fill(accentColor));
    canvas.restore();
  }

  void _drawPackage(Canvas canvas) {
    // 손잡이
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(23, 11, 12, 9),
        const Radius.circular(3.5),
      ),
      _stroke(baseColor, 3),
    );
    // 본체
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(13, 18, 32, 28),
        const Radius.circular(7),
      ),
      _fill(baseColor),
    );
    // 가운데 밴드
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(25, 18, 8, 28),
        const Radius.circular(2),
      ),
      _fill(accentColor),
    );
    // 잠금쇠
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(26, 27, 6, 5),
        const Radius.circular(1.6),
      ),
      _fill(Colors.white, 0.94),
    );
    // 좌우 스티치 라인
    canvas.drawLine(
      const Offset(18, 23),
      const Offset(18, 41),
      _stroke(Colors.white, 1.6, alpha: 0.5),
    );
    canvas.drawLine(
      const Offset(40, 23),
      const Offset(40, 41),
      _stroke(Colors.white, 1.6, alpha: 0.5),
    );
  }

  void _drawCloud(Canvas canvas, Offset center, double alpha) {
    final paint = _fill(Colors.white, alpha);
    canvas.drawCircle(center + const Offset(-7, 1), 5, paint);
    canvas.drawCircle(center, 7, paint);
    canvas.drawCircle(center + const Offset(8, 2), 5.5, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 12, center.dy + 1, 25, 7),
        const Radius.circular(4),
      ),
      paint,
    );
  }

  Path _starPath(Offset center, double radius) {
    final inner = radius * 0.44;
    final points = <Offset>[
      Offset(center.dx, center.dy - radius),
      Offset(center.dx + inner * 0.62, center.dy - inner * 0.38),
      Offset(center.dx + radius, center.dy - radius * 0.08),
      Offset(center.dx + inner * 0.72, center.dy + inner * 0.42),
      Offset(center.dx + radius * 0.52, center.dy + radius),
      Offset(center.dx, center.dy + inner * 0.72),
      Offset(center.dx - radius * 0.52, center.dy + radius),
      Offset(center.dx - inner * 0.72, center.dy + inner * 0.42),
      Offset(center.dx - radius, center.dy - radius * 0.08),
      Offset(center.dx - inner * 0.62, center.dy - inner * 0.38),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path..close();
  }

  Paint _fill(Color color, [double alpha = 1]) {
    return Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
  }

  Paint _stroke(Color color, double width, {double alpha = 1}) {
    return Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = width
      ..isAntiAlias = true;
  }

  @override
  bool shouldRepaint(covariant _CategoryIconPainter oldDelegate) {
    return oldDelegate.art != art ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.accentColor != accentColor;
  }
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

/// 기획전 모음 카드 데이터
class _Curation {
  final String tag;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final String service;

  const _Curation({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.service,
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
