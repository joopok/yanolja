import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/nol_menu.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/provider/auth_provider.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_confirm_dialog.dart';

/// 전체 카테고리 화면
///
/// 실제 NOL "전체 카테고리"를 풀스크린으로 재현합니다.
/// NOL 티켓 / 국내여행 / 해외여행 / 서비스 4개 그룹의 모든 메뉴를
/// 컬러 아이콘 그리드로 보여주고, 각 항목에서 해당 화면으로 이동합니다.
///
/// 메가메뉴 룩을 위해 히어로 배너 → 빠른 이동 → 각 메뉴 그룹 순서로
/// staggered 등장(YanoljaEntrance + YanoljaMotion.stagger)을 적용합니다.
class AllCategoriesScreen extends ConsumerWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      appBar: YanoljaAppBar.sub(
        title: '전체 메뉴',
        subtitle: '필요한 예약 메뉴를 빠르게 찾으세요',
        fallbackRoute: '/home',
        // 백 버튼을 배경 없는 플레인 아이콘으로 렌더한다.
        flatLeading: true,
        // 로그인 상태에서만 우측에 로그아웃 액션을 노출한다.
        actions: user == null
            ? null
            : [
                _LogoutAction(onTap: () => _handleLogout(context, ref)),
              ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            YanoljaSpacing.l,
            YanoljaSpacing.s,
            YanoljaSpacing.l,
            32,
          ),
          children: [
            YanoljaEntrance(
              delay: YanoljaMotion.stagger(0),
              child: _buildHeroBanner(context),
            ),
            const SizedBox(height: YanoljaSpacing.m),
            YanoljaEntrance(
              delay: YanoljaMotion.stagger(1),
              child: _buildQuickDock(context),
            ),
            const SizedBox(height: YanoljaSpacing.l),
            for (var i = 0; i < nolMenuGroups.length; i++) ...[
              YanoljaEntrance(
                delay: YanoljaMotion.stagger(i + 2),
                child: _buildGroup(context, nolMenuGroups[i]),
              ),
              if (i != nolMenuGroups.length - 1)
                const SizedBox(height: YanoljaSpacing.m),
            ],
          ],
        ),
      ),
    );
  }

  /// 로그아웃: 확인 다이얼로그 → 세션 해제 → 로그인 화면으로 이동.
  /// (ProfileScreen에서 옮겨온 동작과 동일하게 fromLogout 플래그를 전달한다.)
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showYanoljaConfirmDialog(
      context: context,
      icon: Icons.logout_rounded,
      title: '로그아웃할까요?',
      message: '현재 계정에서 나갑니다.\n예약 내역은 다시 로그인하면 그대로 확인할 수 있어요.',
      confirmText: '로그아웃',
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(authProvider).signOut();
    if (!context.mounted) return;
    YanoljaToast.show(context, '로그아웃되었습니다.');
    context.go('/login', extra: const {'fromLogout': true});
  }

  /// 상단 브랜드 배너
  Widget _buildHeroBanner(BuildContext context) {
    return YanoljaPressable(
      // /search 는 StatefulShellRoute 브랜치이므로 push가 아닌 go로 이동한다.
      // push 하면 ShellRouteMatch 페이지 키가 중복돼 Navigator 어서션이 크래시한다.
      onTap: () => context.go('/search'),
      borderRadius: BorderRadius.circular(YanoljaRadius.xl),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: YanoljaColors.background,
          borderRadius: BorderRadius.circular(YanoljaRadius.xl),
          border: Border.all(color: YanoljaColors.border),
          boxShadow: const [
            BoxShadow(
              color: YanoljaColors.shadow,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: YanoljaColors.primaryLight,
                borderRadius: BorderRadius.circular(YanoljaRadius.lg),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: YanoljaColors.primary,
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '전체 예약 메뉴',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '숙소, 티켓, 항공, 혜택을 한 화면에서 바로 이동하세요',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: YanoljaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: YanoljaColors.surfaceAlt,
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: YanoljaColors.textSecondary,
                size: 19,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 자주 쓰는 메뉴를 먼저 보여주는 빠른 이동 영역
  Widget _buildQuickDock(BuildContext context) {
    final quickItems = nolQuickMenu
        .where((item) => item.route != '/all-categories')
        .take(6)
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(
          YanoljaSpacing.m, YanoljaSpacing.m, 0, YanoljaSpacing.m),
      decoration: BoxDecoration(
        color: YanoljaColors.background,
        borderRadius: BorderRadius.circular(YanoljaRadius.xl),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(
                right: YanoljaSpacing.m, bottom: YanoljaSpacing.s),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '빠른 이동',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Text(
                  '자주 쓰는 메뉴',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: quickItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _buildQuickTile(context, quickItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTile(BuildContext context, NolMenuItem item) {
    return YanoljaPressable(
      onTap: () => context.push(item.route),
      borderRadius: BorderRadius.circular(YanoljaRadius.lg),
      pressedScale: 0.94,
      child: Container(
        width: 118,
        padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              YanoljaColors.background,
              item.color.withValues(alpha: 0.07),
            ],
          ),
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: item.color.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: item.color.withValues(alpha: 0.09),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MenuIconImage(
                  item: item,
                  size: 48,
                  radius: YanoljaRadius.lg,
                ),
                const Spacer(),
                Icon(
                  Icons.north_east_rounded,
                  color: item.color.withValues(alpha: 0.58),
                  size: 16,
                ),
              ],
            ),
            const Spacer(),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              '바로가기',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: item.color.withValues(alpha: 0.78),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메뉴 그룹 (제목 + 그리드)
  ///
  /// 그룹마다 첫 항목의 컬러를 대표 악센트로 삼아 헤더의 악센트 바·개수 배지에
  /// 반영해 그룹 간 구분감을 강화합니다.
  Widget _buildGroup(BuildContext context, NolMenuGroup group) {
    final accent = group.items.first.color;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        YanoljaSpacing.m,
        YanoljaSpacing.m,
        YanoljaSpacing.m,
        18,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.055),
            YanoljaColors.background,
            YanoljaColors.background,
          ],
          stops: const [0, 0.42, 1],
        ),
        borderRadius: BorderRadius.circular(YanoljaRadius.xl),
        border: Border.all(color: YanoljaColors.border),
        boxShadow: const [
          BoxShadow(
            color: YanoljaColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 그룹 대표 악센트 바 — 그룹별 컬러 정체성
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: YanoljaColors.textPrimary,
                        letterSpacing: -0.45,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      group.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: YanoljaColors.textTertiary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                ),
                child: Text(
                  '${group.items.length}개',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: accent,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: YanoljaSpacing.s,
            childAspectRatio: 0.66,
            children: [
              for (var i = 0; i < group.items.length; i++)
                _buildMenuTile(context, group.items[i]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, NolMenuItem item) {
    return YanoljaPressable(
      onTap: () => context.push(item.route),
      borderRadius: BorderRadius.circular(YanoljaRadius.lg),
      pressedScale: 0.92,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: item.color.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: _MenuIconImage(
              item: item,
              size: 54,
              radius: YanoljaRadius.lg,
            ),
          ),
          const SizedBox(height: YanoljaSpacing.s),
          Text(
            item.label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.18,
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

class _MenuIconImage extends StatelessWidget {
  final NolMenuItem item;
  final double size;
  final double radius;

  const _MenuIconImage({
    required this.item,
    required this.size,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${item.label} 아이콘',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          item.asset,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          excludeFromSemantics: true,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: size * 0.48,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 전체메뉴 앱바 우측 로그아웃 액션.
///
/// 배경 없는 플레인 아이콘. 화면 우측 끝에 바짝 붙지 않도록 우측 여백을 둔다.
class _LogoutAction extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutAction({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        // 앱바 기본 trailing(SizedBox 6) + 우측 8 = 화면 끝에서 약 14px 떨어진다.
        padding: const EdgeInsets.only(right: 8),
        child: Tooltip(
          message: '로그아웃',
          child: Semantics(
            button: true,
            label: '로그아웃',
            child: YanoljaPressable(
              onTap: onTap,
              borderRadius: BorderRadius.circular(YanoljaRadius.squircle),
              pressedScale: 0.94,
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Icon(
                    Icons.logout_rounded,
                    size: 22,
                    color: YanoljaColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
