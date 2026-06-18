import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/provider/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      body: authState.when(
        data: (user) {
          if (user != null) {
            // 로그인 상태
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildProfileHeader(user.email),
                      const SizedBox(height: 8),
                      _buildGradeCard(),
                      const SizedBox(height: 8),
                      _buildQuickActions(),
                      const SizedBox(height: 8),
                      _buildMainMenu(),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildLogoutButton(),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // 로그아웃 상태
            return _buildLoggedOutView(context, theme);
          }
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: YanoljaColors.primary),
        ),
        error: (error, stack) => Center(child: Text('오류 발생: $error')),
      ),
    );
  }

  // 🌸 프로필 헤더 (핑크 액센트, 플랫)
  Widget _buildProfileHeader(String userEmail) {
    final displayName = userEmail.contains('@')
        ? userEmail.split('@')[0]
        : userEmail;

    return Container(
      color: YanoljaColors.background,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            children: [
              // 프로필 이미지
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: YanoljaColors.primaryLight,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=400&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const ColoredBox(
                      color: YanoljaColors.primaryLight,
                      child: Icon(
                        Icons.person_rounded,
                        color: YanoljaColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 이름 / 이메일
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: YanoljaColors.textPrimary,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '님',
                          style: TextStyle(
                            color: YanoljaColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: YanoljaColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // 프로필 수정
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showSnackBar('프로필 수정');
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: YanoljaColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                  ),
                  child: const Text(
                    '프로필 수정',
                    style: TextStyle(
                      color: YanoljaColors.textSecondary,
                      fontSize: 12,
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

  // 💎 등급 / 포인트 카드 (핑크 틴트)
  Widget _buildGradeCard() {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          color: YanoljaColors.primaryLight,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.primaryLight),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildGradeCell(
                icon: Icons.workspace_premium_rounded,
                value: 'VIP',
                label: '회원등급',
              ),
            ),
            Container(
              width: 1,
              height: 44,
              color: YanoljaColors.primary.withValues(alpha: 0.15),
            ),
            Expanded(
              child: _buildGradeCell(
                icon: Icons.savings_rounded,
                value: '15,200P',
                label: '포인트',
              ),
            ),
            Container(
              width: 1,
              height: 44,
              color: YanoljaColors.primary.withValues(alpha: 0.15),
            ),
            Expanded(
              child: _buildGradeCell(
                icon: Icons.confirmation_number_rounded,
                value: '3장',
                label: '쿠폰',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeCell({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Icon(icon, color: YanoljaColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: YanoljaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: YanoljaColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ⚡ 빠른 메뉴 (찜 / 예약 / 리뷰)
  Widget _buildQuickActions() {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionItem(
              icon: Icons.favorite_rounded,
              label: '찜한 숙소',
              onTap: () => context.push('/saved'),
            ),
          ),
          Expanded(
            child: _buildActionItem(
              icon: Icons.receipt_long_rounded,
              label: '예약 내역',
              onTap: () => context.push('/bookings'),
            ),
          ),
          Expanded(
            child: _buildActionItem(
              icon: Icons.rate_review_rounded,
              label: '내 리뷰',
              onTap: () => _showSnackBar('내 리뷰'),
            ),
          ),
          Expanded(
            child: _buildActionItem(
              icon: Icons.history_rounded,
              label: '최근 본 숙소',
              onTap: () => _showSnackBar('최근 본 숙소'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: YanoljaColors.primaryLight,
              borderRadius: BorderRadius.circular(YanoljaRadius.md),
            ),
            child: Icon(icon, color: YanoljaColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: YanoljaColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 📋 메인 메뉴 리스트 (플랫, 헤어라인 구분선)
  Widget _buildMainMenu() {
    final menuItems = <Map<String, Object>>[
      {
        'icon': Icons.campaign_rounded,
        'title': '공지사항',
        'subtitle': '새로운 소식을 확인하세요',
      },
      {
        'icon': Icons.local_offer_rounded,
        'title': '이벤트 & 쿠폰',
        'subtitle': '진행 중인 이벤트 3개',
      },
      {
        'icon': Icons.support_agent_rounded,
        'title': '고객센터',
        'subtitle': '24시간 상담 가능',
      },
      {
        'icon': Icons.shield_rounded,
        'title': '개인정보 보호',
        'subtitle': '보안 설정 관리',
      },
      {
        'icon': Icons.settings_rounded,
        'title': '앱 설정',
        'subtitle': '알림 및 계정 설정',
      },
    ];

    return Container(
      color: YanoljaColors.background,
      child: Column(
        children: [
          const YanoljaSectionHeader(
            title: '더보기',
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          ),
          ...menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildMenuItem(
              icon: item['icon'] as IconData,
              title: item['title'] as String,
              subtitle: item['subtitle'] as String,
              isLast: index == menuItems.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _showSnackBar(title);
        },
        child: Container(
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(
                      color: YanoljaColors.border,
                      width: 1,
                    ),
                  ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: YanoljaColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                ),
                child: Icon(icon, color: YanoljaColors.textSecondary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: YanoljaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
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
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Consumer(builder: (context, ref, child) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showLogoutDialog(context, ref);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: YanoljaColors.textSecondary,
            side: const BorderSide(color: YanoljaColors.border, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(YanoljaRadius.md),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 18),
              SizedBox(width: 8),
              Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              '$message 페이지로 이동합니다.',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: YanoljaColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(YanoljaRadius.md),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: YanoljaColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          ),
          title: const Text(
            '로그아웃',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 19,
              color: YanoljaColors.textPrimary,
            ),
          ),
          content: const Text(
            '정말 로그아웃 하시겠습니까?',
            style: TextStyle(
              fontSize: 15,
              color: YanoljaColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: YanoljaColors.textSecondary,
              ),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authProvider).signOut();
                if (context.mounted) {
                  Navigator.of(context).pop();
                  _showSnackBar('로그아웃되었습니다');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                ),
              ),
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoggedOutView(BuildContext context, ThemeData theme) {
    return Container(
      color: YanoljaColors.background,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: YanoljaColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 44,
                color: YanoljaColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '로그인이 필요해요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '로그인하고 찜 목록과 예약 내역을 관리하세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: YanoljaColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.push('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: YanoljaColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(YanoljaRadius.md),
                  ),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => context.push('/signup'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: YanoljaColors.primary,
                  side: const BorderSide(color: YanoljaColors.primary, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(YanoljaRadius.md),
                  ),
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
