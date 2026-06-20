import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_bottom_nav.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      bottomNavigationBar: const YanoljaBottomNav(selectedBranchIndex: 0),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildTopTabs(context),
                _buildSearchPill(context),
                _sectionGap(),
                _buildCategorySection(context),
                _sectionGap(),
                _buildBenefitSection(context),
                _sectionGap(),
                _buildSupportSection(context),
                const SizedBox(height: 42),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return YanoljaSliverAppBar.sub(
      title: '전체 카테고리',
      fallbackRoute: '/home',
      actions: [
        IconButton(
          onPressed: () => context.go('/saved'),
          tooltip: '찜',
          icon: const Icon(
            Icons.favorite_border_rounded,
            color: YanoljaColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: () => context.go('/my-info'),
          tooltip: '마이',
          icon: const Icon(
            Icons.person_outline_rounded,
            color: YanoljaColors.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildTopTabs(BuildContext context) {
    const tabs = ['홈', '티켓', '쿠폰·혜택', '특가'];

    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          for (final tab in tabs) ...[
            _TopTab(
              label: tab,
              selected: tab == '홈',
              onTap: () => _handleTopTab(context, tab),
            ),
            if (tab != tabs.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchPill(BuildContext context) {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          context.go('/search');
        },
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: YanoljaColors.surfaceAlt,
            borderRadius: BorderRadius.circular(YanoljaRadius.pill),
            border: Border.all(color: YanoljaColors.border),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: YanoljaColors.textSecondary,
                size: 23,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '어디로 놀러갈까요?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: YanoljaColors.textSecondary,
                  ),
                ),
              ),
              Icon(
                Icons.mic_none_rounded,
                color: YanoljaColors.textTertiary,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    final primaryItems = [
      _CategoryItem(
        icon: Icons.hotel_rounded,
        label: '호텔/리조트',
        color: YanoljaColors.primary,
        route: '/hotel',
      ),
      _CategoryItem(
        icon: Icons.house_siding_rounded,
        label: '펜션/풀빌라',
        color: YanoljaColors.mint,
        route: '/pension',
      ),
      _CategoryItem(
        icon: Icons.bed_rounded,
        label: '모텔',
        color: YanoljaColors.primaryPurple,
        route: '/service/motel',
      ),
      _CategoryItem(
        icon: Icons.local_activity_rounded,
        label: '국내레저',
        color: YanoljaColors.sale,
        route: '/service/leisure',
      ),
      _CategoryItem(
        icon: Icons.directions_car_filled_rounded,
        label: '교통/쏘카',
        color: YanoljaColors.accentBlue,
        route: '/service/transport',
      ),
      _CategoryItem(
        icon: Icons.confirmation_number_rounded,
        label: 'NOL 티켓',
        color: YanoljaColors.yellow,
        route: '/ticket',
      ),
      _CategoryItem(
        icon: Icons.flight_takeoff_rounded,
        label: '항공',
        color: YanoljaColors.primary,
        route: '/service/flight',
      ),
      _CategoryItem(
        icon: Icons.public_rounded,
        label: '해외숙소',
        color: YanoljaColors.mint,
        route: '/service/overseas',
      ),
      _CategoryItem(
        icon: Icons.map_rounded,
        label: '해외투어',
        color: YanoljaColors.primaryPurple,
        route: '/service/overseas-tour',
      ),
      _CategoryItem(
        icon: Icons.card_travel_rounded,
        label: '패키지',
        color: YanoljaColors.sale,
        route: '/service/package',
      ),
    ];

    return Container(
      color: YanoljaColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YanoljaSectionHeader(
            title: '카테고리',
            subtitle: '숙소부터 티켓, 교통까지 한 번에',
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
            trailingText: '전체보기',
            onTrailingTap: () => context.push('/all-categories'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: primaryItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 18,
                crossAxisSpacing: 8,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                return _CategoryTile(
                  item: primaryItems[index],
                  onTap: () => _handleCategoryTap(context, primaryItems[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
            child: _NolDayBanner(
              onTap: () => context.push('/service/deals'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitSection(BuildContext context) {
    final benefits = [
      _BenefitItem(
        icon: Icons.local_offer_rounded,
        title: '이달의 쿠폰팩',
        subtitle: '숙소·티켓 할인 쿠폰 모음',
        color: YanoljaColors.primary,
        route: '/service/coupons',
      ),
      _BenefitItem(
        icon: Icons.credit_card_rounded,
        title: 'NOL 카드',
        subtitle: '결제할수록 커지는 추가 혜택',
        color: YanoljaColors.primaryPurple,
        route: '/service/nol-card',
      ),
      _BenefitItem(
        icon: Icons.bolt_rounded,
        title: '놀라운 특가',
        subtitle: '오늘만 열리는 한정가',
        color: YanoljaColors.sale,
        route: '/service/deals',
      ),
    ];

    return Container(
      color: YanoljaColors.background,
      child: Column(
        children: [
          const YanoljaSectionHeader(
            title: '쿠폰·혜택',
            trailingText: '전체 보기',
            padding: EdgeInsets.fromLTRB(20, 22, 20, 12),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
            child: Column(
              children: [
                for (int i = 0; i < benefits.length; i++) ...[
                  _BenefitRow(
                    item: benefits[i],
                    onTap: () => context.push(benefits[i].route),
                  ),
                  if (i != benefits.length - 1)
                    const Divider(
                      height: 1,
                      color: YanoljaColors.divider,
                      indent: 56,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    final supportItems = [
      _SupportItem(
        icon: Icons.receipt_long_rounded,
        title: '예약내역',
        subtitle: '예약, 취소, 환불 상태 확인',
        route: '/bookings',
      ),
      _SupportItem(
        icon: Icons.support_agent_rounded,
        title: '고객센터',
        subtitle: '1644-1346 · 문의/안내',
        route: '/service/support',
      ),
      _SupportItem(
        icon: Icons.campaign_rounded,
        title: '공지사항',
        subtitle: 'NOL의 새로운 소식',
        route: '/service/notice',
      ),
      _SupportItem(
        icon: Icons.tune_rounded,
        title: '앱 설정',
        subtitle: '알림, 위치, 계정 관리',
        route: '/settings',
      ),
    ];

    return Container(
      color: YanoljaColors.background,
      child: Column(
        children: [
          const YanoljaSectionHeader(
            title: '문의·안내',
            padding: EdgeInsets.fromLTRB(20, 22, 20, 8),
          ),
          for (int i = 0; i < supportItems.length; i++) ...[
            _SupportRow(
              item: supportItems[i],
              onTap: () => _handleSupportTap(context, supportItems[i]),
            ),
            if (i != supportItems.length - 1)
              const Divider(
                height: 1,
                color: YanoljaColors.divider,
                indent: 76,
              ),
          ],
        ],
      ),
    );
  }

  Widget _sectionGap() {
    return Container(height: 8, color: YanoljaColors.surfaceAlt);
  }

  void _handleCategoryTap(BuildContext context, _CategoryItem item) {
    HapticFeedback.lightImpact();
    context.push(item.route ?? '/service/deals');
  }

  void _handleSupportTap(BuildContext context, _SupportItem item) {
    HapticFeedback.lightImpact();
    context.push(item.route ?? '/service/support');
  }

  void _handleTopTab(BuildContext context, String tab) {
    HapticFeedback.selectionClick();
    switch (tab) {
      case '홈':
        context.go('/home');
        return;
      case '티켓':
        context.push('/service/leisure');
        return;
      case '쿠폰·혜택':
        context.push('/service/coupons');
        return;
      case '특가':
        context.push('/service/deals');
        return;
    }
  }
}

class _TopTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TopTab({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(YanoljaRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? YanoljaColors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: selected ? Colors.white : YanoljaColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.color,
    this.route,
  });
}

class _CategoryTile extends StatelessWidget {
  final _CategoryItem item;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(YanoljaRadius.md),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(YanoljaRadius.md),
            ),
            child: Icon(item.icon, color: item.color, size: 25),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: YanoljaColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NolDayBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _NolDayBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(YanoljaRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: YanoljaColors.primary,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '국내여행 준비 NOLDAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '호텔·펜션·티켓 특가를 한 번에 확인하세요',
                    style: TextStyle(
                      color: Color(0xFFEAF0FF),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}

class _BenefitRow extends StatelessWidget {
  final _BenefitItem item;
  final VoidCallback onTap;

  const _BenefitRow({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(YanoljaRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: YanoljaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: YanoljaColors.textTertiary,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;

  const _SupportItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.route,
  });
}

class _SupportRow extends StatelessWidget {
  final _SupportItem item;
  final VoidCallback onTap;

  const _SupportRow({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: YanoljaColors.surfaceAlt,
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: Icon(
                item.icon,
                color: YanoljaColors.textPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: YanoljaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: YanoljaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: YanoljaColors.textTertiary,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }
}
