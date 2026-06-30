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

/// 전체 카테고리 화면 — 클린 화이트 카드 메가메뉴
///
/// NOL 브랜드의 화이트 포워드·플랫 정체성에 맞춘 디자인. 그라데이션 없이
/// 화이트 카드 + 얇은 헤어라인 + 절제된 그림자로 구성하고, 색은 카테고리
/// 클레이 아이콘이 전담한다. 히어로(검색) → 빠른 이동 → 메뉴 그룹 순서로
/// staggered 등장(YanoljaEntrance)을 적용한다.
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
            YanoljaSpacing.m,
            YanoljaSpacing.l,
            36,
          ),
          children: [
            YanoljaEntrance(
              delay: YanoljaMotion.stagger(0),
              child: _buildHero(context),
            ),
            const SizedBox(height: YanoljaSpacing.l),
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

  /// 상단 히어로 — 화이트 카드 + 실제 검색바(검색 진입).
  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(YanoljaSpacing.m),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: YanoljaColors.primaryLight,
                  borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                  border: Border.all(
                    color: YanoljaColors.primary.withValues(alpha: 0.10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: YanoljaColors.primary.withValues(alpha: 0.10),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Image.asset(
                  NolMenuIcons.allReservationHub,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.grid_view_rounded,
                    color: YanoljaColors.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 13),
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
                    SizedBox(height: 3),
                    Text(
                      '숙소·티켓·항공·혜택을 한 곳에서',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: YanoljaColors.textSecondary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 검색바 — 화이트 포워드, 홈 검색바와 동일한 톤
          YanoljaPressable(
            // /search 는 StatefulShellRoute 브랜치이므로 push가 아닌 go로 이동한다.
            onTap: () => context.go('/search'),
            borderRadius: BorderRadius.circular(YanoljaRadius.search),
            child: Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(14, 0, 8, 0),
              decoration: BoxDecoration(
                color: YanoljaColors.surfaceSearch,
                borderRadius: BorderRadius.circular(YanoljaRadius.search),
                border: Border.all(color: YanoljaColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: YanoljaColors.textTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Text(
                      '여행지, 숙소, 티켓 검색',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: YanoljaColors.textTertiary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: YanoljaColors.primary,
                      borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          const Padding(
            padding: EdgeInsets.only(right: YanoljaSpacing.m, bottom: 12),
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
            height: 112,
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
        width: 116,
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
        decoration: BoxDecoration(
          color: YanoljaColors.background,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
          boxShadow: const [
            BoxShadow(
              color: YanoljaColors.shadow,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MenuIconImage(item: item, size: 44, radius: YanoljaRadius.md),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: YanoljaColors.textTertiary,
                  size: 18,
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
                fontWeight: FontWeight.w800,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 1),
            const Text(
              '바로가기',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: YanoljaColors.textTertiary,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메뉴 그룹 (화이트 카드 + 깔끔한 아이콘 그리드)
  ///
  /// 그룹마다 첫 항목의 컬러를 대표 악센트로 삼아, 얇은 악센트 바·개수 배지에만
  /// 절제해서 반영한다(배경은 화이트 유지).
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
        color: YanoljaColors.background,
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
              // 그룹 대표 악센트 바 — 그룹별 컬러 정체성(플랫)
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
            mainAxisSpacing: 16,
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
    // 화이트 포워드: 중립 그레이 플레이트 + 헤어라인 위에 컬러 클레이 아이콘.
    return YanoljaPressable(
      onTap: () => context.push(item.route),
      borderRadius: BorderRadius.circular(YanoljaRadius.lg),
      pressedScale: 0.92,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: YanoljaColors.surfaceAlt,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: YanoljaColors.border),
            ),
            child: _MenuIconImage(
              item: item,
              size: 46,
              radius: YanoljaRadius.md,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            item.label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.16,
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
    final displaySize = _MenuIconDisplaySize.fromAsset(item.asset, size);

    return Semantics(
      label: '${item.label} 아이콘',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          item.asset,
          width: displaySize.width,
          height: displaySize.height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          excludeFromSemantics: true,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: displaySize.width,
              height: displaySize.height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: displaySize.shortestSide * 0.48,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MenuIconDisplaySize {
  static const double _sourceCanvasExtent = 256;

  final double width;
  final double height;

  const _MenuIconDisplaySize(this.width, this.height);

  double get shortestSide => width < height ? width : height;

  static _MenuIconDisplaySize fromAsset(String asset, double size) {
    final sourceBounds = _ticketSourceBounds[asset];
    if (sourceBounds == null) {
      return _MenuIconDisplaySize(size, size);
    }

    final scale = size / _sourceCanvasExtent;
    return _MenuIconDisplaySize(
      sourceBounds.width * scale,
      sourceBounds.height * scale,
    );
  }
}

class _SourceIconBounds {
  final double width;
  final double height;

  const _SourceIconBounds(this.width, this.height);
}

/// NOL 티켓 아이콘은 256px 원본 캔버스에서 차지하던 실제 bbox 크기로 렌더한다.
///
/// 배경 제거 후 PNG는 실선 기준으로 잘려 있지만, 화면에서 그대로 46px 폭에 맞추면
/// 예전보다 과하게 커지고 가로로 늘린 것처럼 보여 원본 캔버스 비율을 복원한다.
const Map<String, _SourceIconBounds> _ticketSourceBounds = {
  NolMenuIcons.ticketMusical: _SourceIconBounds(165, 101),
  NolMenuIcons.ticketConcert: _SourceIconBounds(187, 88),
  NolMenuIcons.ticketSports: _SourceIconBounds(185, 92),
  NolMenuIcons.ticketExhibition: _SourceIconBounds(198, 94),
  NolMenuIcons.ticketClassicDance: _SourceIconBounds(187, 95),
  NolMenuIcons.ticketKidsFamily: _SourceIconBounds(185, 92),
  NolMenuIcons.ticketTheater: _SourceIconBounds(182, 86),
};

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
