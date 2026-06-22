import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/nol_menu.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

/// 전체 카테고리 화면
///
/// 실제 NOL "전체 카테고리"를 풀스크린으로 재현합니다.
/// NOL 티켓 / 국내여행 / 해외여행 / 서비스 4개 그룹의 모든 메뉴를
/// 컬러 아이콘 그리드로 보여주고, 각 항목에서 해당 화면으로 이동합니다.
class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanoljaColors.background,
      appBar: const YanoljaAppBar.sub(
        title: '전체 카테고리',
        fallbackRoute: '/home',
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _buildHeroBanner(context),
            const SizedBox(height: 24),
            for (var i = 0; i < nolMenuGroups.length; i++) ...[
              YanoljaEntrance(
                delay: YanoljaMotion.stagger(i, start: 90, step: 55),
                child: _buildGroup(context, nolMenuGroups[i]),
              ),
              if (i != nolMenuGroups.length - 1) const SizedBox(height: 26),
            ],
          ],
        ),
      ),
    );
  }

  /// 상단 브랜드 배너
  Widget _buildHeroBanner(BuildContext context) {
    return YanoljaPressable(
      onTap: () => context.push('/search'),
      child: const YanoljaPremiumHero(
        badge: 'ALL CATEGORIES',
        title: 'NOL의 모든 여행을\n한 곳에서',
        subtitle: '숙소, 티켓, 항공, 혜택까지 필요한 메뉴를 빠르게 찾아보세요',
        icon: Icons.grid_view_rounded,
        gradient: [YanoljaColors.primary, YanoljaColors.primaryPurple],
        metrics: [
          YanoljaHeroMetric(label: '메뉴', value: '24개'),
          YanoljaHeroMetric(label: '검색', value: '탭해서 시작'),
        ],
      ),
    );
  }

  /// 메뉴 그룹 (제목 + 그리드)
  Widget _buildGroup(BuildContext context, NolMenuGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: YanoljaColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              group.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                group.subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: YanoljaColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 18,
          crossAxisSpacing: 8,
          childAspectRatio: 0.82,
          children: [
            for (var i = 0; i < group.items.length; i++)
              YanoljaEntrance(
                delay: YanoljaMotion.stagger(i, start: 0, step: 18),
                beginOffset: const Offset(0, 0.03),
                child: _buildMenuTile(context, group.items[i]),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuTile(BuildContext context, NolMenuItem item) {
    return YanoljaPressable(
      onTap: () => context.push(item.route),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(YanoljaRadius.lg),
              border: Border.all(color: item.color.withValues(alpha: 0.10)),
            ),
            child: Icon(item.icon, color: item.color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: YanoljaColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
