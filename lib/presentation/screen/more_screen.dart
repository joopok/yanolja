import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/nol_menu.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/provider/search_provider.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_bottom_nav.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';
import 'package:yanolja_clone/presentation/widget/nol_footer.dart';

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
                YanoljaEntrance(child: _buildTopTabs(context)),
                YanoljaEntrance(
                  delay: const Duration(milliseconds: 55),
                  child: _buildSearchPill(context, ref),
                ),
                _sectionGap(),
                YanoljaEntrance(
                  delay: const Duration(milliseconds: 100),
                  child: _buildCategorySection(context),
                ),
                _sectionGap(),
                YanoljaEntrance(
                  delay: const Duration(milliseconds: 150),
                  child: _buildBenefitSection(context),
                ),
                _sectionGap(),
                YanoljaEntrance(
                  delay: const Duration(milliseconds: 200),
                  child: _buildSupportSection(context),
                ),
                _sectionGap(),
                const NolFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return YanoljaSliverAppBar.sub(
      title: '전체 메뉴',
      subtitle: '예약과 혜택 메뉴를 한 곳에서',
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
        const SizedBox(width: YanoljaSpacing.xs),
      ],
    );
  }

  Widget _buildTopTabs(BuildContext context) {
    const tabs = ['전체', '티켓', '쿠폰·혜택', '특가'];

    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          for (final tab in tabs) ...[
            _TopTab(
              label: tab,
              selected: tab == '전체',
              onTap: () => _handleTopTab(context, tab),
            ),
            if (tab != tabs.last) const SizedBox(width: YanoljaSpacing.s),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchPill(BuildContext context, WidgetRef ref) {
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
          padding: const EdgeInsets.fromLTRB(18, 0, 7, 0),
          decoration: BoxDecoration(
            color: YanoljaColors.surfaceAlt,
            borderRadius: BorderRadius.circular(YanoljaRadius.pill),
            border: Border.all(color: YanoljaColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: YanoljaColors.textSecondary,
                size: 23,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '어떤 예약을 찾고 있나요?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: YanoljaColors.textSecondary,
                  ),
                ),
              ),
              Semantics(
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
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: YanoljaColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_none_rounded,
                      color: YanoljaColors.primary,
                      size: 20,
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

  Widget _buildCategorySection(BuildContext context) {
    final primaryItems = nolQuickMenu
        .where((item) => item.route != '/all-categories')
        .map(
          (item) => _CategoryItem(
            icon: item.icon,
            label: item.label,
            color: item.color,
            route: item.route,
          ),
        )
        .toList();

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
                  onTap: () =>
                      _handleCategoryTap(context, primaryItems[index]),
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
          YanoljaSectionHeader(
            title: '쿠폰·혜택',
            trailingText: '전체보기',
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
            onTrailingTap: () => context.push('/service/coupons'),
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
                indent: 78,
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
      case '전체':
        context.go('/home');
        return;
      case '티켓':
        context.push('/ticket');
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: YanoljaSpacing.s),
        decoration: BoxDecoration(
          color: selected ? YanoljaColors.primary : Colors.transparent,
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
          const SizedBox(height: YanoljaSpacing.s),
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
          boxShadow: [
            BoxShadow(
              color: YanoljaColors.primary.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
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
                  SizedBox(height: YanoljaSpacing.xs),
                  Text(
                    '호텔·펜션·티켓 특가를 한 번에 확인하세요',
                    style: TextStyle(
                      color: YanoljaColors.primaryLight,
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
        padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
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
