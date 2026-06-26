import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/provider/auth_provider.dart';
import 'package:yanolja_clone/presentation/provider/notification_provider.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_confirm_dialog.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // primaryLight 표면 위 카드의 테두리/구분선 색 (혜택 요약 카드 전용).
  static const Color _benefitBorder = Color(0xFFDCE5FF);

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);

    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      body: authState.when(
        data: (user) {
          if (user == null) return _buildLoggedOutView();
          return _buildLoggedInView(user);
        },
        loading: () => _buildProfileSkeleton(),
        error: (error, stack) => Container(
          color: YanoljaColors.background,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: YanoljaColors.textTertiary,
                size: 44,
              ),
              const SizedBox(height: 14),
              const Text(
                '정보를 불러오지 못했어요',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: YanoljaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => ref.invalidate(authStateChangesProvider),
                style: TextButton.styleFrom(
                  foregroundColor: YanoljaColors.textSecondary,
                ),
                child: const Text(
                  '다시 시도',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 인증 상태 로딩 중 마이페이지 레이아웃을 미러링하는 스켈레톤
  /// (다른 화면의 스켈레톤 로딩과 진입 체감 일관화).
  Widget _buildProfileSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFEDEEF0),
        highlightColor: const Color(0xFFF7F8FA),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _skBox(56, 56, 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _skBox(150, 18, 6),
                        const SizedBox(height: 9),
                        _skBox(90, 13, 6),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _skBox(double.infinity, 92, 16),
              const SizedBox(height: 16),
              _skBox(double.infinity, 118, 16),
              const SizedBox(height: 20),
              for (var i = 0; i < 4; i++) ...[
                _skBox(double.infinity, 52, 12),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _skBox(double w, double h, double r) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }

  Widget _buildLoggedInView(AppUser user) {
    final unread = ref.watch(unreadNotificationCountProvider);
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        YanoljaSliverAppBar.main(
          title: '마이',
          subtitle: '예약과 혜택을 한 번에 관리하세요',
          actions: [
            _buildHeaderIcon(
              icon: Icons.notifications_none_rounded,
              label: '알림',
              badgeCount: unread,
              onTap: () => context.push('/notifications'),
            ),
            _buildHeaderIcon(
              icon: Icons.settings_outlined,
              label: '설정',
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              YanoljaEntrance(
                delay: YanoljaMotion.stagger(0, start: 40, step: 45),
                child: _buildMyHeader(user),
              ),
              _sectionGap(),
              YanoljaEntrance(
                delay: YanoljaMotion.stagger(1, start: 40, step: 45),
                child: _buildBenefitSummary(),
              ),
              _sectionGap(),
              YanoljaEntrance(
                delay: YanoljaMotion.stagger(2, start: 40, step: 45),
                child: _buildReservationPanel(),
              ),
              _sectionGap(),
              YanoljaEntrance(
                delay: YanoljaMotion.stagger(3, start: 40, step: 45),
                child: _buildQuickActions(),
              ),
              _sectionGap(),
              YanoljaEntrance(
                delay: YanoljaMotion.stagger(4, start: 40, step: 45),
                child: _buildMainMenu(),
              ),
              const SizedBox(height: YanoljaSpacing.m),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l),
                child: _buildLogoutButton(),
              ),
              const SizedBox(height: 72),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMyHeader(AppUser user) {
    final displayName = user.displayName.isNotEmpty
        ? user.displayName
        : user.email.split('@').first;

    return Container(
      color: YanoljaColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: YanoljaColors.primary,
                    borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                  ),
                  child: const Text(
                    'N',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                color: YanoljaColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const Text(
                            '님',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: YanoljaColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _buildMiniBadge('NOL 멤버십'),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              user.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: YanoljaColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/profile-edit');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: YanoljaColors.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '수정',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return Semantics(
      label: badgeCount > 0 ? '$label, 안 읽음 $badgeCount건' : label,
      button: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            icon: Icon(icon, color: YanoljaColors.textPrimary, size: 24),
            tooltip: label,
          ),
          if (badgeCount > 0)
            Positioned(
              right: 4,
              top: 4,
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
                  badgeCount > 9 ? '9+' : '$badgeCount',
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
    );
  }

  Widget _buildMiniBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: YanoljaColors.textPrimary,
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildBenefitSummary() {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: YanoljaColors.primaryLight,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: _benefitBorder),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: YanoljaColors.primary,
                      borderRadius: BorderRadius.circular(YanoljaRadius.md),
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '놀수록 놀라운 혜택',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: YanoljaColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          '쿠폰과 포인트를 한 번에 확인하세요',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: YanoljaColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _benefitBorder),
            Row(
              children: [
                Expanded(
                  child: _buildBenefitCell(
                    value: 'VIP',
                    label: '회원등급',
                    icon: Icons.workspace_premium_rounded,
                    route: '/service/membership',
                  ),
                ),
                _buildBenefitDivider(),
                Expanded(
                  child: _buildBenefitCell(
                    value: '15,200P',
                    label: 'NOL 포인트',
                    icon: Icons.savings_rounded,
                    route: '/service/points',
                  ),
                ),
                _buildBenefitDivider(),
                Expanded(
                  child: _buildBenefitCell(
                    value: '3장',
                    label: '받은 쿠폰',
                    icon: Icons.confirmation_number_rounded,
                    route: '/service/coupons',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCell({
    required String value,
    required String label,
    required IconData icon,
    String? route,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        if (route != null) {
          context.push(route);
        } else {
          _showSnackBar('$label 내역을 확인합니다.');
        }
      },
      borderRadius: BorderRadius.circular(YanoljaRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: YanoljaSpacing.m),
        child: Column(
          children: [
            Icon(icon, color: YanoljaColors.primary, size: 21),
            const SizedBox(height: 7),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: YanoljaColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitDivider() {
    return Container(
      width: 1,
      height: 46,
      color: _benefitBorder,
    );
  }

  Widget _buildReservationPanel() {
    return Container(
      color: YanoljaColors.background,
      child: Column(
        children: [
          YanoljaSectionHeader(
            title: '내 여행',
            trailingText: '전체 보기',
            onTrailingTap: () => context.push('/bookings'),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/bookings');
              },
              borderRadius: BorderRadius.circular(YanoljaRadius.lg),
              child: Container(
                padding: const EdgeInsets.all(YanoljaSpacing.m),
                decoration: BoxDecoration(
                  color: YanoljaColors.surface,
                  borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                  border: Border.all(color: YanoljaColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: YanoljaColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(YanoljaRadius.md),
                      ),
                      child: const Icon(
                        Icons.luggage_rounded,
                        color: YanoljaColors.primary,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '다가오는 예약 3건',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: YanoljaColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          SizedBox(height: YanoljaSpacing.xs),
                          Text(
                            '7월 서울, 8월 부산, 9월 강릉',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: YanoljaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: YanoljaColors.textPrimary,
                        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = <_MyShortcut>[
      _MyShortcut(
        icon: Icons.receipt_long_rounded,
        label: '예약내역',
        color: YanoljaColors.primary,
        onTap: () => context.push('/bookings'),
      ),
      _MyShortcut(
        icon: Icons.favorite_rounded,
        label: '찜',
        color: YanoljaColors.sale,
        onTap: () => context.go('/saved'),
      ),
      _MyShortcut(
        icon: Icons.confirmation_number_rounded,
        label: '쿠폰함',
        color: YanoljaColors.primaryPurple,
        onTap: () => context.push('/service/coupons'),
      ),
      _MyShortcut(
        icon: Icons.history_rounded,
        label: '최근 본 상품',
        color: YanoljaColors.mint,
        onTap: () => context.push('/service/recent'),
      ),
    ];

    return Container(
      color: YanoljaColors.background,
      child: Column(
        children: [
          const YanoljaSectionHeader(
            title: '바로가기',
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
            child: Row(
              children: [
                for (final action in actions)
                  Expanded(child: _buildShortcutItem(action)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutItem(_MyShortcut action) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        action.onTap();
      },
      borderRadius: BorderRadius.circular(YanoljaRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: Icon(action.icon, color: action.color, size: 25),
            ),
            const SizedBox(height: YanoljaSpacing.s),
            Text(
              action.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: YanoljaColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenu() {
    return Container(
      color: YanoljaColors.background,
      child: Column(
        children: [
          const YanoljaSectionHeader(
            title: 'NOL 서비스',
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          ),
          _buildMenuItem(
            icon: Icons.local_offer_rounded,
            title: '쿠폰·혜택',
            subtitle: '오늘 받을 수 있는 혜택 5개',
            badge: 'NOL',
            route: '/service/coupons',
          ),
          _buildMenuItem(
            icon: Icons.credit_card_rounded,
            title: 'NOL 카드',
            subtitle: '결제할수록 커지는 여행 혜택',
            badge: '혜택',
            route: '/service/nol-card',
          ),
          _buildMenuItem(
            icon: Icons.support_agent_rounded,
            title: '고객센터',
            subtitle: '예약, 취소, 환불 문의',
            route: '/service/support',
          ),
          _buildMenuItem(
            icon: Icons.campaign_rounded,
            title: '공지사항',
            subtitle: 'NOL의 새로운 소식',
            route: '/service/notice',
          ),
          _buildMenuItem(
            icon: Icons.tune_rounded,
            title: '앱 설정',
            subtitle: '알림과 계정 설정',
            route: '/settings',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    String? route,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          if (route != null) {
            context.push(route);
          } else {
            _showSnackBar('$title 화면으로 이동합니다.');
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l, vertical: 15),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: YanoljaColors.divider),
                  ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: YanoljaColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                ),
                child: Icon(icon, color: YanoljaColors.textPrimary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: YanoljaColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: YanoljaColors.primaryLight,
                              borderRadius:
                                  BorderRadius.circular(YanoljaRadius.sm),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: YanoljaColors.primary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _showLogoutDialog();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: YanoljaColors.textSecondary,
          side: const BorderSide(color: YanoljaColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(YanoljaRadius.md),
          ),
        ),
        child: const Text(
          '로그아웃',
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildLoggedOutView() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        YanoljaSliverAppBar.main(
          title: '마이',
          subtitle: '로그인하고 NOL 혜택을 확인하세요',
          actions: [
            _buildHeaderIcon(
              icon: Icons.settings_outlined,
              label: '설정',
              onTap: () => context.push('/settings'),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: YanoljaEntrance(
            delay: YanoljaMotion.stagger(0, start: 40, step: 45),
            child: Container(
              color: YanoljaColors.background,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 74,
                            height: 74,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: YanoljaColors.primary,
                              borderRadius:
                                  BorderRadius.circular(YanoljaRadius.xl),
                            ),
                            child: const Text(
                              'NOL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            '로그인하고 NOL 혜택을 확인하세요',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: YanoljaColors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: YanoljaSpacing.s),
                          const Text(
                            '쿠폰, 포인트, 예약 내역을 한 번에 볼 수 있어요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: YanoljaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => context.push('/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: YanoljaColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.md),
                          ),
                        ),
                        child: const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => context.push('/signup'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: YanoljaColors.textPrimary,
                          side: const BorderSide(color: YanoljaColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.md),
                          ),
                        ),
                        child: const Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
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
        SliverToBoxAdapter(child: _sectionGap()),
        SliverToBoxAdapter(
          child: YanoljaEntrance(
            delay: YanoljaMotion.stagger(1, start: 40, step: 45),
            child: _buildLoggedOutBenefits(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedOutBenefits() {
    return Container(
      color: YanoljaColors.background,
      child: Column(
        children: const [
          YanoljaSectionHeader(
            title: '회원 전용 혜택',
            subtitle: 'NOL에서 바로 쓸 수 있는 쿠폰과 특가',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                Expanded(
                  child: _LoggedOutBenefitCard(
                    icon: Icons.confirmation_number_rounded,
                    title: '쿠폰팩',
                    subtitle: '매월 업데이트',
                    color: YanoljaColors.primary,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _LoggedOutBenefitCard(
                    icon: Icons.bolt_rounded,
                    title: '특가 알림',
                    subtitle: '인기 상품 먼저',
                    color: YanoljaColors.sale,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionGap() {
    return Container(height: 8, color: YanoljaColors.surfaceAlt);
  }

  void _showSnackBar(String message) {
    YanoljaToast.show(context, message);
  }

  Future<void> _showLogoutDialog() async {
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
    if (!mounted) return;
    _showSnackBar('로그아웃되었습니다.');
    // 로그아웃 후에는 마이 화면에 머무르지 않고 로그인 화면으로 이동합니다.
    // fromLogout 플래그를 전달해, 로그인 화면의 백버튼·시스템 백이
    // 로그아웃된 마이 화면으로 되돌아가지 않고 홈으로 가도록 합니다.
    context.go('/login', extra: const {'fromLogout': true});
  }
}

class _MyShortcut {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MyShortcut({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _LoggedOutBenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _LoggedOutBenefitCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: YanoljaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
